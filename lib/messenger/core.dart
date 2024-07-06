import 'dart:async';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart'
    as notif;
import 'package:s5/s5.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/definitions/s5embed.dart';
import 'package:vup_chat/functions/general.dart';
import 'package:vup_chat/functions/thumbhash.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';

class MsgCore {
  final S5? s5;
  final MessageDatabase db;
  final Bluesky? bskySession;
  final BlueskyChat? bskyChatSessoion;
  Timer? _timerShort; // To manage the periodic task
  Timer? _timerLong;

  // Named constructor
  MsgCore.custom({
    this.s5,
    required this.db,
    this.bskySession,
    this.bskyChatSessoion,
  });

  // Unnamed constructor that initializes the database internally
  MsgCore({
    S5? s5,
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

  void _startBackgroundTask() {
    _timerShort = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // grab message lsit
      _populateListViewDBATProto();
    });
    _timerLong = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // grab all chats
      _fetchAllChats();
      // also make sure the sessions are logged in
      if (session == null ||
          session!.session == null ||
          session!.session!.active == false) {
        session = await tryLogIn(null, null);
      }
    });
  }

  void stopBackgroundTask() {
    _timerShort?.cancel();
    _timerLong?.cancel();
    _timerShort = null;
    _timerLong = null;
  }

  void _initNotifications() async {
    await notif.PlatformNotifier.I.init(appName: "Vup Chat");
    // check if you have already asked
    final bool? notifAllow = preferences.getBool("notification-permissions");
    if (notifAllow == null) {
      bool? isAccepted = isDesktop()
          ? true
          : await notif.PlatformNotifier.I.requestPermissions();
      preferences.setBool("notification-permissions", isAccepted ?? false);
    }
  }

  Stream<List<ChatRoomData>> subscribeChatRoom() {
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
      final Sender snd = Sender(
          did: profile.did,
          displayName: profile.displayName ?? "",
          avatarUrl: profile.avatar);
      await db.checkAndInsertSenderATProto(snd);
      return snd;
    } else {
      return possibleSender;
    }
  }

  Future<String?> getChatIDFromMessageID(String mID) async {
    return db.getChatRoomIdFromMessageId(mID);
  }

  Future<ChatRoomData?> getChatRoomFromChatID(String chatID) async {
    return db.getChatRoomFromChatID(chatID);
  }

  Future<List<Message>> searchMessages(String query, String? chatID) async {
    return await db.searchMessages(query, chatID);
  }

  // TODO create own local message ID's to associate with BSKY ID to speed up sending
  Future<void> sendMessage(String text, String chatID, Sender sender) async {
    // TODO: persist to DB BEFORE sneding to atproto to make things snappier
    if (chatSession != null && text.isNotEmpty) {
      final MessageView message = (await chatSession!.convo
              .sendMessage(convoId: chatID, message: MessageInput(text: text)))
          .data;
      // Ignore this return because shouldn't notify for own message obv
      db.checkAndInsertMessageATProto(message, chatID, false, sender, null);
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
      final CID cid = await s5!.api.uploadBlob(await file.readAsBytes());
      final S5Embed imageEmbed = S5Embed(
          cid: cid.toBase58(),
          caption: caption,
          thumbhash: hash.toString(),
          $type: "S5-photo");
      logger.d(imageEmbed.toJson());
      final MessageView message = (await chatSession!.convo.sendMessage(
              convoId: chatID,
              message: MessageInput(
                  embed: UConvoMessageEmbed.unknown(data: imageEmbed.toJson()),
                  text:
                      "An S5 compatible client like Vup Chat is required to view this media.")))
          .data;
      logger.d("image sent with caption ${message.text}");
      // Ignore this return because shouldn't notify for own message obv
      db.checkAndInsertMessageATProto(
          message, chatID, false, sender, imageEmbed);
      logger.d("inserted message");
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

  void _populateListViewDBATProto() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await db.checkAndInsertChatRoom(convo);
      }
    }
  }

  void _fetchAllChats() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await checkForMessageUpdatesATProto(convo.id);
      }
    }
  }

  Future<void> checkForMessageUpdatesATProto(String chatID) async {
    if (chatSession != null) {
      final GetMessagesOutput ref =
          (await chatSession!.convo.getMessages(convoId: chatID)).data;
      final List<MessageView> messages = convertToMessageViews(ref.messages);

      for (var message in messages) {
        final Sender snd = await getSenderFromDID(message.sender.did);
        final bool _ = await db.checkAndInsertMessageATProto(
            message, chatID, true, snd, null);
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
}
