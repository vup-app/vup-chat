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
  Timer? _timer; // To manage the periodic task

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _populateListViewDBATProto();
    });
  }

  void stopBackgroundTask() {
    _timer?.cancel();
    _timer = null;
  }

  Stream<List<ChatRoomData>> subscribeChatRoom() {
    return db.watchChatRooms();
  }

  Stream<List<Message>> subscribeChat(String chatID) {
    return db.watchChatForMessage(chatID);
  }

  Future<void> sendMessage(String text, String chatID) async {
    if (chatSession != null && text.isNotEmpty) {
      final MessageView message = (await chatSession!.convo
              .sendMessage(convoId: chatID, message: MessageInput(text: text)))
          .data;
      db.checkAndInsertMessageATProto(message, chatID, false);
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

  void checkForMessageUpdatesATProto(String chatID) async {
    if (chatSession != null) {
      final GetMessagesOutput ref =
          (await chatSession!.convo.getMessages(convoId: chatID)).data;
      final List<MessageView> messages = convertToMessageViews(ref.messages);
      for (var message in messages) {
        await db.checkAndInsertMessageATProto(message, chatID, true);
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
