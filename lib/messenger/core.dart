import 'dart:async';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';

class MsgCore {
  final S5 s5;
  final MessageDatabase db;
  final Bluesky? bskySession;
  final BlueskyChat? bskyChatSession;
  Timer? _timerShort; // To manage the periodic task
  Timer? _timerLong;

  // Named constructor
  MsgCore.custom({
    required this.s5,
    required this.db,
    this.bskySession,
    this.bskyChatSession,
  });

  // Unnamed constructor that initializes the database internally
  MsgCore({
    required S5 s5,
    Bluesky? bskySession,
    BlueskyChat? bskyChatSession,
  }) : this.custom(
          s5: s5,
          db: MessageDatabase(), // Initialize the database internally
          bskySession: bskySession,
          bskyChatSession: bskyChatSession,
        );

  void init() async {
    startBackgroundTask();
  }

  void startBackgroundTask() {
    _timerShort = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _populateListViewDBATProto();
    });
    _timerLong = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _fetchAllChats();
    });
  }

  void stopBackgroundTask() {
    _timerShort?.cancel();
    _timerLong?.cancel();
    _timerShort = null;
    _timerLong = null;
  }

  Stream<List<ChatRoomData>> subscribeChatRoom() {
    return db.watchChatRooms();
  }

  Stream<List<Message>> subscribeChat(String chatID) {
    return db.watchChatForMessage(chatID);
  }

  Future<Sender?> getSenderFromDID(String did) async {
    final possibleSender = await db.getSenderByDID(did);
    if (possibleSender == null && session != null) {
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

  Future<List<Message>> searchMessages(String query, String? chatID) async {
    return await db.searchMessages(query, chatID);
  }

  Future<void> sendMessage(String text, String chatID, Sender sender) async {
    if (chatSession != null && text.isNotEmpty) {
      final MessageView message = (await chatSession!.convo
              .sendMessage(convoId: chatID, message: MessageInput(text: text)))
          .data;
      db.checkAndInsertMessageATProto(message, chatID, false, sender);
    }
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
        final Sender? snd = await getSenderFromDID(message.sender.did);
        await db.checkAndInsertMessageATProto(message, chatID, true, snd!);
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
