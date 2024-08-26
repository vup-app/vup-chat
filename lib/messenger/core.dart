import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as n;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lib5/identity.dart';
import 'package:lib5/node.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s5/s5.dart' as s5lib;
import 'package:universal_io/io.dart' as io;
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/bsky/log_out.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/definitions/notification_payload.dart';
import 'package:vup_chat/definitions/s5_embed.dart';
import 'package:vup_chat/functions/s5.dart';
import 'package:vup_chat/functions/thumbhash.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/messenger/lock.dart';
import 'package:vup_chat/mls5/mls5.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/init_router.dart';
import 'package:universal_io/io.dart';
import 'package:vup_chat/mls5/model/message.dart' as m;

class MsgCore {
  final MessageDatabase db;
  final Lock _lock = Lock();
  s5lib.S5? s5;
  Bluesky? bskySession;
  BlueskyChat? bskyChatSession;
  bool _firstSync =
      false; // disabled for now, TODO: find better way to not spam users on first sync
  // handles notificaitons
  n.FlutterLocalNotificationsPlugin? notifier;
  // Keeps track of notification channels
  Map<String, int> messageNotifChannels = {};
  // Keeps track if app is in foreground or background
  StreamSubscription<FGBGType>? subscription;
  // Allows canceling and starting of background tasks
  NeatPeriodicTaskScheduler? backgroundChatFetchScheduler;
  NeatPeriodicTaskScheduler? dbBackupScheduler;

  // Named constructor
  MsgCore.custom({
    this.s5,
    required this.db,
    this.bskySession,
    this.bskyChatSession,
  });

  // Unnamed constructor that initializes the database internally
  MsgCore()
      : this.custom(
          db: MessageDatabase(), // Initialize the database internally
        );

  // -------- INIT FUNCTIONS --------

  Future<void> init() async {
    await attemptLogin(null, null);

    backgroundChatFetchScheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(seconds: 5),
      name: 'background-chat-fetch-task',
      timeout: const Duration(seconds: 30),
      task: () async {
        await _populateListViewDBATProto();
        await Future.delayed(const Duration(seconds: 5));
        await _fetchAllChats();
      },
      minCycle: const Duration(seconds: 1),
    );

    dbBackupScheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(hours: 2),
      name: 'db-backup-task',
      timeout: const Duration(hours: 1),
      task: backupSQLiteToS5,
      minCycle: const Duration(hours: 1),
    );

    backgroundChatFetchScheduler?.start();
    dbBackupScheduler?.start();

    if (!kIsWeb) {
      _initNotifications();
    }

    _fetchMLSAfterOffline();
    _watchForMLSUpdates();
  }

  Future<void> msgInitS5() async {
    s5 = await initS5();
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

  // This function watches the groupChat stream to make sure all MLS chats
  // are being listened to
  void _watchForMLSUpdates() async {
    Map<String, StreamSubscription<void>> listeners =
        {}; // contains listeners to
    // Watch the groupChat stream
    subscribeChatRoom().listen(
      (chatRooms) async {
        for (ChatRoom chatRoom in chatRooms) {
          // if group now has MLS ID, subscribe to it and add subscription to map
          if (chatRoom.mlsChatID != null &&
              !listeners.keys.contains(chatRoom.id)) {
            GroupState groupState = mls5.group(chatRoom.mlsChatID!);
            listeners[chatRoom.id] =
                groupState.messageListStateNotifier.stream.listen((_) async {
              String otherDID =
                  ((await msg.getSendersFromDIDList(chatRoom.members))
                      .firstWhere((t) => t.did != did)).did;
              Sender sender = await getSenderFromDID(otherDID);
              if (did !=
                  (groupState.messagesMemory.first.msg as m.TextMessage).did) {
                String localMessageID = await db.insertMessageLocal(
                  (groupState.messagesMemory.first.msg as m.TextMessage).text,
                  chatRoom.id,
                  sender,
                  null,
                  true,
                  (groupState.messagesMemory.first.msg as m.TextMessage).id,
                );
                Message? msg = await db.getMessageFromLocalID(localMessageID);
                if (msg != null) {
                  await db.updateChatRoomsLastMessage(chatRoom.id, msg);
                  await notifyUserOfMessage(localMessageID, chatRoom.id);
                  logger.d(
                      (groupState.messagesMemory.first.msg as m.TextMessage)
                          .text);
                }
              }
            });
            // if group no longer has MLS id, dispose of it's listener and remove from map
          } else if (chatRoom.mlsChatID == null &&
              listeners.keys.contains(chatRoom.id)) {
            await listeners[chatRoom.id]?.cancel();
            listeners.remove(chatRoom.id);
          }
        }
      },
    );
  }

  void _fetchMLSAfterOffline() async {
    // Get the iterator for the entries of the map
    final iterator = mls5.groups.entries.iterator;

    // Iterate through the map using the iterator
    while (iterator.moveNext()) {
      final GroupState groupState = iterator.current.value;
      final String? chatID =
          await db.getChatRoomIDFromMLSGroupID(groupState.groupId);
      // Now fetch history of group and insert any messages that need inserting
      // This truncates the message history at the previous 100 messages so the client
      // doesn't rescan a huge amount of messages
      final int mml = groupState.messagesMemory.length;
      for (var msg
          in groupState.messagesMemory.sublist(0, (mml < 99) ? mml : 99)) {
        // TODO: implement checking and inserting
        m.TextMessage message = (msg.msg as m.TextMessage);
        Sender? sender = await db.getSenderByDID(message.did);
        Message? messageExists = await db.getMessageFromMLSID(message.id);
        // Message DOES NOT exist
        if (messageExists == null && chatID != null && sender != null) {
          String localMessageID = await db.insertMessageLocal(
              message.text, chatID, sender, null, true, message.id);
          Message? msg = await db.getMessageFromLocalID(localMessageID);
          if (msg != null) {
            await db.updateChatRoomsLastMessage(chatID, msg);
          }
        }
      }
    }
  }

  Future<void> attemptLogin(String? user, String? password) async {
    Session? session;
    if (user != null && password != null) {
      session = await tryLogIn(user, password);
    } else {
      session = await tryLogIn(null, null);
    }
    if (session != null) {
      bskySession = Bluesky.fromSession(
        session,
      );
      bskyChatSession = BlueskyChat.fromSession(session);
    }
  }

  // -------- STREAM SUBSCRIPTIONS --------

  Stream<List<ChatRoom>> subscribeChatRoom() {
    return db.watchChatRooms();
  }

  Stream<List<Message>> subscribeChat(String chatID, bool starredOnly) {
    if (starredOnly) {
      return db.watchChatForMessageStarred(chatID);
    } else {
      return db.watchChatForMessage(chatID);
    }
  }

  Future<Sender> getSenderFromDID(String did) async {
    final possibleSender = await db.getSenderByDID(did);
    if (possibleSender == null) {
      final ActorProfile profile =
          (await bskySession!.actor.getProfile(actor: did)).data;
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
          displayName: profile.displayName ?? "null",
          handle: profile.handle,
          avatar: avatarBytes);
      await db.insertOrUpdateSender(snd);
      return snd;
    } else {
      return possibleSender;
    }
  }

  Future<List<Sender>> getSendersFromDIDList(String didList) async {
    List<dynamic> memberDIDs = jsonDecode(didList);
    List<Sender> sndrs = [];
    for (String o in memberDIDs) {
      sndrs.add(await msg.getSenderFromDID(o));
    }
    return sndrs;
  }

  // -------- DATABASE GETTERS --------

  Future<String?> getChatIDFromMessageID(String mID) async {
    return db.getChatRoomsIdFromMessageId(mID);
  }

  Future<ChatRoom?> getChatRoomFromChatID(String chatID) async {
    ChatRoom? crd = await db.getChatRoomFromChatID(chatID);
    if (crd == null && bskyChatSession != null) {
      final GetConvoOutput convoInfo =
          (await bskyChatSession!.convo.getConvo(convoId: chatID)).data;
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

  // -------- DATABASE ACTIONS --------

  Future<void> sendMessage(
      String text, String chatID, Sender sender, bool? sendEncrypted) async {
    // If sendNoEncryption is set to null it will default to FALSE (as you should
    // generally send to encrypted)
    final ChatRoom? chatRoomData = await getChatRoomFromChatID(chatID);
    if (chatRoomData != null && sendEncrypted == null) {
      if (chatRoomData.mlsChatID != null) {
        sendEncrypted = true;
      } else {
        sendEncrypted = false;
      }
    }
    if (sendEncrypted == null || sendEncrypted == false) {
      if (bskyChatSession != null && text.isNotEmpty) {
        final MessageView message = (await bskyChatSession!.convo.sendMessage(
                convoId: chatID, message: MessageInput(text: text)))
            .data;
        // Ignore this return because shouldn't notify for own message obv
        String messageID = await db.insertMessageLocal(
            message.text, chatID, sender, null, false, null);
        await db.checkAndInsertMessageATProto(
            messageID, message, chatID, false, sender, null);
      }
    } else if (chatRoomData?.mlsChatID != null) {
      String? mlsMessageID =
          await mls5.group(chatRoomData!.mlsChatID!).sendMessage(text, null);
      String localMessageID = await db.insertMessageLocal(
          text, chatID, sender, null, true, mlsMessageID);
      Message? msg = await db.getMessageFromLocalID(localMessageID);
      if (msg != null) {
        await db.updateChatRoomsLastMessage(chatID, msg);
      }
    } else {
      logger.e("Contitions are not met to send message.");
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
    if (bskyChatSession != null && s5 != null) {
      String? hash = await getThumbhashFromXFile(file);
      final s5lib.CID cid = await s5!.api.uploadBlob(await file.readAsBytes());
      final S5Embed imageEmbed = S5Embed(
          cid: cid.toBase58(),
          caption: caption,
          thumbhash: hash.toString(),
          $type: "app.vup.chat.embed.image");
      final MessageView message = (await bskyChatSession!.convo.sendMessage(
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
      // get the chatroom info for each
      final ChatRoom? chatRoom = await db.getChatRoomFromChatID(chatID);
      if (chatRoom != null) {
        final List<String> notifLevels = chatRoom.notificationLevel.split("-");
        final bool currMuted =
            (notifLevels[0] == "disable") && (notifLevels[1] == "disable");
        // invert this because we're toggling and flipping
        if (currMuted == true) {
          // if null just assume it's not muted to not mess up remote state
          await bskyChatSession!.convo.unmuteConvo(convoId: chatID);
          await db.setNotificationLevel(chatID, "normal", "normal");
        } else {
          // should cover all cases
          await bskyChatSession!.convo.muteConvo(convoId: chatID);
          await db.setNotificationLevel(chatID, "disable", "disable");
        }
      } else {
        logger.e("failed to fetch chatroom");
      }
    }
  }

  Future<void> toggleChatHidden(List<String> chatIDs) async {
    for (String chatID in chatIDs) {
      await db.chatHiddenHelper(chatID, "toggle-hide");

      // bsky doesn't impl hidden chats so this is purely local
    }
  }

  Future<void> toggleChatPin(List<String> chatIDs) async {
    for (String chatID in chatIDs) {
      await db.chatPinHelper(chatID, "toggle-pin");

      // bsky doesn't impl pinned chats so this is purely local
    }
  }

  Future<void> toggleChatStar(List<String> chatIDs) async {
    for (String chatID in chatIDs) {
      await db.msgStarHelper(chatID, "toggle-star");

      // bsky doesn't impl starred chats so this is purely local
    }
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
          final Sender snd = await msg.getSenderFromDID(payload.did!);
          sendMessage(resp.input!, payload.chatID, snd, null);
        }
        // If the notification is simply clicked on, go to the chat channel
        // TODO: Figure out why pushing from this context creates dirty build state
        else if (resp.notificationResponseType ==
            n.NotificationResponseType.selectedNotification) {
          vupSplitViewKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatIndividualPage(
                      id: payload.chatID,
                      starredOnly: false,
                    )),
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
    if (io.Platform.isAndroid) {
      notifier
          ?.resolvePlatformSpecificImplementation<
              n.AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> deleteMessages(List<Message> msgs, String chatID) async {
    // First delete locally to make things fast
    for (Message msg in msgs) {
      try {
        logger.d("deleting local: ${msg.id}");
        await db.deleteLocalMessage(msg.id);
      } catch (e) {
        logger.e(e);
      }
    }
    // then delete remote if necesary
    for (Message msg in msgs) {
      if (msg.bskyID != null) {
        try {
          logger.d("deleting bsky: ${msg.bskyID}");
          await bskyChatSession?.convo
              .deleteMessageForSelf(convoId: chatID, messageId: msg.bskyID!);
          await db.deleteLocalMessage(
              msg.id); // just in case it got fetched again (crude)
        } catch (e) {
          logger.e(e);
        }
      }
    }
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
        // check if chatroom exists first to make sure it gets inserted right
        if (await db.getChatRoomFromChatID(convo.id) == null) {
          db.checkAndInsertChatRoom(convo);
        }
        await checkForMessageUpdatesATProto(convo.id);
      }
    }
  }

  Future<void> checkForMessageUpdatesATProto(String chatID) async {
    // add lock here to keep the db from colliding by getting written to by
    // different threads
    await _lock.acquire();
    try {
      if (bskyChatSession != null) {
        final GetMessagesOutput ref =
            (await bskyChatSession!.convo.getMessages(convoId: chatID)).data;
        final List<MessageView> messages = convertToMessageViews(ref.messages);

        for (var message in messages) {
          final Sender snd = await getSenderFromDID(message.sender.did);
          // gotta check if it already exists or not
          String? localMessageID =
              await db.getMessageIDFromBskyValues(chatID, message.id);
          if (localMessageID == null) {}
          localMessageID ??= await db.insertMessageLocal(
              message.text, chatID, snd, null, false, null);
          final bool shouldNotify = await db.checkAndInsertMessageATProto(
              localMessageID, message, chatID, true, snd, null);
          shouldNotify ? notifyUserOfMessage(localMessageID, chatID) : null;
        }
      }
    } catch (e) {
      // Yes I know this is a crude way of getting the error code, I'll fix it later
      if (e.toString().contains("400")) {
        attemptLogin(null, null);
      }
    } finally {
      _lock.release();
      _firstSync = false;
    }
  }

  Future<void> notifyUserOfMessage(String localMessageID, String chatID) async {
    // Check if this is first sync or not
    // We don't want to spam the user with notifications from an initial sync
    // when the app opens

    final bool allowNotifGlobal =
        (preferences.getBool("notif-global") ?? false);

    // Get chatRoom from DB
    final ChatRoom? chatRoom = await db.getChatRoomFromChatID(chatID);

    // Params:
    // - ChatRoom is NOT null
    // - NOT the first sync
    // - IN the background OR the current chat isn't the focused one
    // - Global Notifications are allowed
    // - Per message notifications are enabled
    if (chatRoom != null &&
        !_firstSync &&
        (inBackground || chatID != currentChatID) &&
        allowNotifGlobal &&
        (chatRoom.notificationLevel.split("-")[1] != "disable")) {
      // Grab message from DB
      final Message? msg = await db.getMessageFromLocalID(localMessageID);
      final Sender? snd =
          (msg != null) ? await db.getSenderByDID(msg.senderDid) : null;

      if (msg != null && msg.senderDid != did && snd != null) {
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
          groupKey: chatRoom.id,
          setAsGroupSummary: false,
          actions: <n.AndroidNotificationAction>[
            const n.AndroidNotificationAction(
              'text_reply_action',
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
        // n.AndroidNotificationDetails groupSummaryNotificationDetails =
        //     n.AndroidNotificationDetails(
        //   chatRoom.id,
        //   chatRoom.roomName,
        //   priority: n.Priority.high,
        //   groupKey: chatRoom.id, // Same group key as above
        //   setAsGroupSummary: true, // Set this notification as the group summary
        //   onlyAlertOnce:
        //       true, // Ensure the summary notification doesn't cause repeated alerts
        // );
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
        await notifier?.show(channel, chatRoom.roomName,
            "${snd.displayName}: ${msg.message}", details,
            payload: payload);
      }
    }
  }

  // WARNING: This is not a safe function to call as it deletes the local DB
  Future<void> nukeDB() async {
    // TODO: Make this work on web
    if (!kIsWeb) {
      // We use `path_provider` to find a suitable path to store our data in.
      final appDir = await getApplicationSupportDirectory();
      final dbPath = join(appDir.path, 'db.sqlite');
      await File(dbPath).delete();
      // Also kill shared preferences for good luck
      await preferences.clear();
    }
  }

  // -------- COMMON FUNCTIONS --------

  List<MessageView> convertToMessageViews(
      List<UConvoMessageView> uConvoMessages) {
    return uConvoMessages
        .whereType<
            UConvoMessageViewMessageView>() // Filter only the messageView type
        .map((uConvoMessageView) =>
            uConvoMessageView.data) // Extract the MessageView data
        .toList();
  }

  /// Takes seed & nodeURL and does the magic to make sure everything is authenticated
  Future<void> logInS5(String seed, String? nodeURL) async {
    if (nodeURL == null || nodeURL.isEmpty) {
      nodeURL = "https://s5.ninja"; // default to red's node
    }
    if (s5 != null) {
      // Checks to make sure it is compliant with the S5 seed spec
      validatePhrase(seed, crypto: s5!.api.crypto);
      await s5!.recoverIdentityFromSeedPhrase(seed);
      // now check if already registered on node
      List<String>? urls;
      // then check if already registered
      if ((s5!.api as S5NodeAPIWithIdentity).accounts.isNotEmpty) {
        Map<dynamic, dynamic> data =
            (s5!.api as S5NodeAPIWithIdentity).accounts;
        final Map<String, dynamic> accounts = (data['accounts'] as Map).map(
          (key, value) => MapEntry(key as String, value),
        );
        urls =
            accounts.values.map((account) => account['url'] as String).toList();
        // And if the nodeURL isn't on the seed already, authenticate on that server
      }
      if (urls == null || !urls.contains(nodeURL)) {
        logger.d("Registering @ $nodeURL");
        await s5!.registerOnNewStorageService(
          nodeURL,
        );
      }
      // make sure to persist this for later use AFTER sucsess
      await secureStorage.write(key: "seed", value: seed);
      preferences.setBool("disable-s5", false);
    }
  }

  Future<void> logOutBsky() async {
    bskySession = await tryLogOut();
  }
}
