import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:s5/s5.dart' as s5lib;
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/definitions/notificationPayload.dart';
import 'package:vup_chat/definitions/s5embed.dart';
import 'package:vup_chat/functions/thumbhash.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/messenger/lock.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/init_router.dart';

class MsgCore {
  final s5lib.S5? s5;
  final MessageDatabase db;
  final Bluesky? bskySession;
  final BlueskyChat? bskyChatSessoion;
  final Lock _lock = Lock();
  bool _firstSync =
      false; // disabled for now, TODO: find better way to not spam users on first sync
  // handles notificaitons
  n.FlutterLocalNotificationsPlugin? notifier;
  // Keeps track of notification channels
  Map<String, int> messageNotifChannels = {};
  StreamSubscription<FGBGType>? subscription;

  // Named constructor
  MsgCore.custom({
    this.s5,
    required this.db,
    this.bskySession,
    this.bskyChatSessoion,
  });

  // Unnamed constructor that initializes the database internally
  MsgCore({
    s5lib.S5? s5,
    Bluesky? bskySession,
    BlueskyChat? bskyChatSession,
  }) : this.custom(
          s5: s5,
          db: MessageDatabase(), // Initialize the database internally
          bskySession: bskySession,
          bskyChatSessoion: bskyChatSession,
        );

  void init() async {
    _startBackgroundTask();
    _initNotifications();
  }

  void _startBackgroundTask() async {
    while (true) {
      // grab message lsit
      await _populateListViewDBATProto();
      await Future.delayed(const Duration(seconds: 5));
      // grab all chats, add lock to make sure to only insert from here when
      // background task is running
      await _fetchAllChats();
      // also make sure the sessions are logged in
      await Future.delayed(const Duration(seconds: 5));
      if (session == null ||
          session!.session == null ||
          session!.session!.active == false) {
        session = await tryLogIn(null, null);
      }
    }
  }

  void _initNotifications() async {
    notifier = n.FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const n.LinuxInitializationSettings initializationSettingsLinux =
        n.LinuxInitializationSettings(defaultActionName: 'Open notification');
    const n.AndroidInitializationSettings initializationSettingsAndroid =
        n.AndroidInitializationSettings('@mipmap/launcher_icon');
    const n.InitializationSettings initializationSettings =
        n.InitializationSettings(
            linux: initializationSettingsLinux,
            android: initializationSettingsAndroid);
    await notifier?.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  Stream<List<ChatRoom>> subscribeChatRoom() {
    return db.watchChatRooms();
  }

  Stream<List<Message>> subscribeChat(String chatID) {
    return db.watchChatForMessage(chatID);
  }

  Future<Sender> getSenderFromDID(String did) async {
    final possibleSender = await db.getSenderByDID(did);
    if (possibleSender == null) {
      final ActorProfile profile =
          (await session!.actor.getProfile(actor: did)).data;
      Uint8List? avatarBytes;
      try {
        http.Response response = await http.get(
          Uri.parse(profile.avatar!),
        );
        avatarBytes = response.bodyBytes;
      } catch (e) {
        logger.d(e);
      }
      final Sender snd = Sender(
          did: profile.did,
          displayName: profile.displayName ?? "",
          avatar: avatarBytes);
      await db.checkAndInsertSenderATProto(snd);
      return snd;
    } else {
      return possibleSender;
    }
  }

  Future<List<Sender>> getSendersFromDIDList(String didList) async {
    List<dynamic> memberDIDs = jsonDecode(didList);
    List<Sender> sndrs = [];
    for (String o in memberDIDs) {
      sndrs.add(await msg!.getSenderFromDID(o));
    }
    return sndrs;
  }

  Future<String?> getChatIDFromMessageID(String mID) async {
    return db.getChatRoomsIdFromMessageId(mID);
  }

  Future<ChatRoom?> getChatRoomFromChatID(String chatID) async {
    ChatRoom? crd = await db.getChatRoomFromChatID(chatID);
    if (crd == null && bskyChatSessoion != null) {
      final GetConvoOutput convoInfo =
          (await bskyChatSessoion!.convo.getConvo(convoId: chatID)).data;
      await db.checkAndInsertChatRoom(convoInfo.convo);
    }
    return await db.getChatRoomFromChatID(chatID);
  }

  Future<List<Message>> searchMessages(String query, String? chatID) async {
    return await db.searchMessages(query, chatID);
  }

  Future<List<ChatRoom>> searchChatRooms(
    String query,
  ) async {
    return await db.searchChatRooms(query);
  }

  // TODO create own local message ID's to associate with BSKY ID to speed up sending
  Future<void> sendMessage(String text, String chatID, Sender sender) async {
    // TODO: persist to DB BEFORE sneding to atproto to make things snappier
    if (chatSession != null && text.isNotEmpty) {
      final MessageView message = (await chatSession!.convo
              .sendMessage(convoId: chatID, message: MessageInput(text: text)))
          .data;
      // Ignore this return because shouldn't notify for own message obv
      String messageID =
          await db.insertMessageLocal(message.text, chatID, sender, null);
      await db.checkAndInsertMessageATProto(
          messageID, message, chatID, false, sender, null);
    }
  }

  Future<void> sendImage(
      String caption, String chatID, Sender sender, XFile file) async {
    // we want this to be snappy so there are 3 steps
    // Step 1: Generate thumbhash & persist to DB
    // Step 2: Generate CID & persist that to DB
    // Step 3: Send that off to ATProto to be persisted

    // But right now I have to pregenerate everything before sending the
    // message because ID's are controlled by BSKY, must fix this to snap
    // everything up
    if (chatSession != null && s5 != null) {
      String? hash = await getThumbhashFromXFile(file);
      final s5lib.CID cid = await s5!.api.uploadBlob(await file.readAsBytes());
      final S5Embed imageEmbed = S5Embed(
          cid: cid.toBase58(),
          caption: caption,
          thumbhash: hash.toString(),
          $type: "app.vup.chat.embed.image");
      final MessageView message = (await chatSession!.convo.sendMessage(
              convoId: chatID,
              message: MessageInput(
                  embed: UConvoMessageEmbedUnknown(data: imageEmbed.toJson()),
                  text:
                      "An s5lib.S5 compatible client like Vup Chat is required to view this media.")))
          .data;
      logger.d("now the message view: ${message.toJson()}");
      // Ignore this return because shouldn't notify for own message obv
      // db.checkAndInsertMessageATProto(
      //     message, chatID, false, sender, imageEmbed);
    }
  }

  Future<void> toggleChatMutes(List<String> chatIDs) async {
    for (String chatID in chatIDs) {
      // modes
      // 1: Mute
      // 2: Unmute
      // 3: Toggle -> default for now
      await db.chatMuteHelper(chatID, 3);

      // gotta check current state in db and write that to bsky
      bool? currMuted = await db.isMuted(chatID);
      if (currMuted == false) {
        // if null just assume it's not muted to not mess up remote state
        await chatSession!.convo.unmuteConvo(convoId: chatID);
      } else {
        // should cover all cases
        await chatSession!.convo.muteConvo(convoId: chatID);
      }
    }
  }

  Future<void> toggleChatHidden(List<String> chatIDs) async {
    for (String chatID in chatIDs) {
      // modes
      // 1: Hide
      // 2: Unhide
      // 3: Toggle -> default for now
      await db.chatHiddenHelper(chatID, 3);

      // bsky doesn't impl hidden chats so this is purely local
    }
  }

  // TODO: Impl deleting chats
  Future<void> deleteChats(List<String> chatIDs) async {
    for (String _ in chatIDs) {}
  }

  Future<void> _populateListViewDBATProto() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await db.checkAndInsertChatRoom(convo);
      }
    }
  }

  Future<void> _fetchAllChats() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await checkForMessageUpdatesATProto(convo.id);
      }
    }
  }

  Future<void> checkForMessageUpdatesATProto(String chatID) async {
    // add lock here to keep the db from colliding by getting written to by
    // different threads
    await _lock.acquire();
    try {
      if (chatSession != null) {
        final GetMessagesOutput ref =
            (await chatSession!.convo.getMessages(convoId: chatID)).data;
        final List<MessageView> messages = convertToMessageViews(ref.messages);

        for (var message in messages) {
          final Sender snd = await getSenderFromDID(message.sender.did);
          // gotta check if it already exists or not
          String? localMessageID =
              await db.getMessageIDFromBskyValues(chatID, message.id);
          if (localMessageID == null) {}
          localMessageID ??=
              await db.insertMessageLocal(message.text, chatID, snd, null);
          final bool shouldNotify = await db.checkAndInsertMessageATProto(
              localMessageID, message, chatID, true, snd, null);
          shouldNotify ? notifyUser(localMessageID, chatID) : null;
        }
      }
    } finally {
      _lock.release();
      _firstSync = false;
    }
  }

  Future<void> notifyUser(String localMessageID, String chatID) async {
    // Check if this is first sync or not
    // We don't want to spam the user with notifications from an initial sync
    // when the app opens

    final bool allowNotifGlobal =
        (preferences.getBool("notif-global") ?? false);
    logger.d(
        "(!$_firstSync && ($inBackground || ${chatID != currentChatID}) && $allowNotifGlobal)");

    if (!_firstSync &&
        (inBackground || chatID != currentChatID) &&
        allowNotifGlobal) {
      logger.d("got in");
      // Grab message & chat room from DB
      final Message? msg = await db.getMessageFromLocalID(localMessageID);
      final Sender? snd =
          (msg != null) ? await db.getSenderByDID(msg.senderDid) : null;
      final ChatRoom? chatRoom = await db.getChatRoomFromChatID(chatID);
      if (msg != null &&
          msg.senderDid != did &&
          chatRoom != null &&
          snd != null) {
        // LINUX CONFIG
        // TODO: Figure out why icon isn't working on linux
        n.LinuxNotificationDetails linuxDetails = n.LinuxNotificationDetails(
            icon: n.AssetsLinuxIcon("static/icon.svg"));
        // ANDROID CONFIG
        n.AndroidNotificationDetails androidNotificationDetails =
            n.AndroidNotificationDetails(
          chatRoom.id,
          chatRoom.roomName,
          priority: n.Priority.high,
          ticker: 'ticker',
          category: n.AndroidNotificationCategory.message,
          actions: <n.AndroidNotificationAction>[
            const n.AndroidNotificationAction(
              'text_id_1',
              'Reply',
              showsUserInterface: true,
              inputs: <n.AndroidNotificationActionInput>[
                n.AndroidNotificationActionInput(
                  label: 'Enter a message',
                ),
              ],
            ),
          ],
        );
        n.NotificationDetails details = n.NotificationDetails(
            linux: linuxDetails, android: androidNotificationDetails);
        // checks if notif channel exists, if it doesn't create it
        // This is to allow chats to be grouped together
        late int channel;
        if (messageNotifChannels.containsKey(chatRoom.id)) {
          messageNotifChannels[chatRoom.id] =
              messageNotifChannels[chatRoom.id] ?? 0 + 1;
          channel = (messageNotifChannels[chatRoom.id] ?? 0) + 1;
        } else {
          Random rand = Random();
          final int idStart = rand.nextInt(10000);
          messageNotifChannels[chatRoom.id] = idStart;
          channel = idStart;
        }
        final payload =
            jsonEncode(NotificationPayload(did: snd.did, chatID: chatID))
                .toString();
        await notifier!.show(channel, chatRoom.roomName,
            "${snd.displayName}: ${msg.message}", details,
            payload: payload);
      }
    }
  }

  List<MessageView> convertToMessageViews(
      List<UConvoMessageView> uConvoMessages) {
    return uConvoMessages
        .whereType<
            UConvoMessageViewMessageView>() // Filter only the messageView type
        .map((uConvoMessageView) =>
            uConvoMessageView.data) // Extract the MessageView data
        .toList();
  }

  MessageDatabase getDB() {
    return db;
  }

  Future<void> setRoomName(String chatID, String newRoomName) async {
    db.changeRoomName(chatID, newRoomName);
  }

  Future<void> onDidReceiveNotificationResponse(
      n.NotificationResponse resp) async {
    // Check for payload
    if (resp.payload != null && resp.payload!.isNotEmpty) {
      try {
        NotificationPayload payload =
            NotificationPayload.fromJson(jsonDecode(resp.payload!));

        // If there is an action and an attached message, send that as a message
        if (resp.notificationResponseType ==
                n.NotificationResponseType.selectedNotificationAction &&
            resp.input != null &&
            resp.input!.isNotEmpty) {
          final Sender? snd = await msg?.getSenderFromDID(payload.did!);
          if (snd != null) {
            sendMessage(
              resp.input!,
              payload.chatID,
              snd,
            );
          }
        }
        // If the notification is simply clicked on, go to the chat channel
        // TODO: Figure out why pushing from this context creates dirty build state
        else if (resp.notificationResponseType ==
            n.NotificationResponseType.selectedNotification) {
          vupSplitViewKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatIndividualPage(id: payload.chatID)),
            (Route<dynamic> route) => route.isFirst,
          );
        } else {
          vupSplitViewKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const InitRouter()),
              (Route<dynamic> route) => route.isFirst);
        }
      } catch (e) {
        logger.e("Failed to fetch payload: $e");
      }
    }
  }

  Future<void> requestPerms() async {
    if (Platform.isAndroid) {
      notifier
          ?.resolvePlatformSpecificImplementation<
              n.AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }
}
