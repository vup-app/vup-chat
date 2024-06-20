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
    required MessageDatabase db,
    Bluesky? bskySession,
    BlueskyChat? bskyChatSession,
  }) : this.custom(
          s5: s5,
          db: db, // Initialize the database internally
          bskySession: bskySession,
          bskyChatSession: bskyChatSession,
        );

  void populateListViewDB() async {
    final ListConvosOutput? ref = await getChatTimeline();

    if (ref != null) {
      for (var convo in ref.convos) {
        await db.checkAndInsertMessageList(convo);
      }
    }
  }
}
