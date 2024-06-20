import 'dart:async';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
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

  Stream<List<ChatListData>> subscribeChatList() {
    return db.watchChatLists();
  }

  void init() async {
    startBackgroundTask();
  }

  void startBackgroundTask() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _populateListViewDBATProto();
    });
  }

  void stopBackgroundTask() {
    _timer?.cancel();
    _timer = null;
  }

  void _populateListViewDBATProto() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await db.checkAndInsertChatList(convo);
      }
    }
  }
}
