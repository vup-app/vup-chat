import 'dart:convert';

import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:drift/drift.dart';
import 'dart:io' as io;
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

class Senders extends Table {
  TextColumn get did => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {did};
}

class Content extends Table {
  TextColumn get cid => text()();

  @override
  Set<Column> get primaryKey => {cid};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get revision => text()();
  TextColumn get message => text()();
  TextColumn get senderDid =>
      text().customConstraint('REFERENCES senders(did) NOT NULL')();
  TextColumn get replyTo =>
      text().nullable().customConstraint('REFERENCES messages(id)')();
  DateTimeColumn get sentAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatList extends Table {
  TextColumn get id => text()();
  TextColumn get rev => text()();
  TextColumn get members => text()(); // Serialized JSON
  TextColumn get lastMessage => text()(); // Serialized JSON
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatListMessages extends Table {
  TextColumn get chatId =>
      text().customConstraint('REFERENCES messages(id) NOT NULL')();
  TextColumn get chatListId =>
      text().customConstraint('REFERENCES chat_list(id) NOT NULL')();

  @override
  Set<Column> get primaryKey => {chatId, chatListId};
}

// And here are all the function defintions
@DriftDatabase(tables: [Senders, Content, Messages, ChatList, ChatListMessages])
class MessageDatabase extends _$MessageDatabase {
  MessageDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Stream to watch messages for a list
  Stream<List<Message>> watchChatForMessage(String chatID) {
    final query = select(messages).join([
      innerJoin(
          chatListMessages, chatListMessages.chatId.equalsExp(messages.id)),
    ])
      ..where(chatListMessages.chatListId.equals(chatID))
      ..orderBy([
        OrderingTerm(expression: messages.sentAt, mode: OrderingMode.asc),
      ]);

    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(messages)).toList());
  }

  // Stream to watch message lists
  Stream<List<ChatListData>> watchChatLists() {
    return (select(chatList).join([
      innerJoin(
          chatListMessages, chatListMessages.chatListId.equalsExp(chatList.id)),
    ])
          ..orderBy([OrderingTerm.desc(chatList.lastUpdated)]))
        .watch()
        .map((rows) => rows.map((row) => row.readTable(chatList)).toList());
  }

  // Check if a sender exists and insert if not
  Future<void> checkAndInsertSenderATProto(ProfileViewBasic sender) async {
    final senderExists = await (select(senders)
          ..where((tbl) => tbl.did.equals(sender.did)))
        .getSingleOrNull();
    if (senderExists == null) {
      into(senders).insert(SendersCompanion.insert(
        did: sender.did,
        displayName: sender.displayName ?? "",
        avatarUrl: Value(sender.avatar),
      ));
    }
  }

  // Check if a message exists and insert if not
  Future<void> checkAndInsertMessageATProto(MessageView message) async {
    final messageExists = await (select(messages)
          ..where((tbl) => tbl.id.equals(message.id)))
        .getSingleOrNull();
    if (messageExists == null) {
      // Check and insert the sender of the message
      final sender = message.sender;
      await checkAndInsertSenderATProto(ProfileViewBasic(
        did: sender.did,
        handle: '', // Handle not provided here, set it appropriately
        displayName: '', // Display name not provided here, set it appropriately
        avatar: '', // Avatar not provided here, set it appropriately
        associated: const ProfileAssociated(
          type: '',
          lists: 0,
          feedgens: 0,
          labeler: false,
          chat: ActorProfileAssociatedChat(type: '', allowIncoming: ''),
        ),
        viewer: const ActorViewer(
          isMuted: false,
          isBlockedBy: false,
          mutedByList: null,
          blockingByList: null,
          blocking: null,
          following: null,
          followedBy: null,
        ),
        labels: [],
        chatDisabled: false,
      ));

      // Insert the message
      into(messages).insert(MessagesCompanion.insert(
        id: message.id,
        revision: message.rev,
        message: message.text,
        senderDid: message.sender.did,
        replyTo: const Value(null), // ATProto doesn't support this
        sentAt: message.sentAt,
      ));
    }
  }

  // Check if a message list exists and insert if not
  Future<void> checkAndInsertChatList(ConvoView convo) async {
    final chatListExists = await (select(chatList)
          ..where((tbl) => tbl.id.equals(convo.id)))
        .getSingleOrNull();

    if (chatListExists == null) {
      // Serialize members to JSON
      final List<Map<String, dynamic>> membersJson = convo.members
          .map((member) => {
                'did': member.did,
                'handle': member.handle,
                'displayName': member.displayName,
                'avatar': member.avatar,
                // Add other fields as needed
              })
          .toList();

      // Serialize lastMessage to JSON
      Map<String, dynamic>? lastMessageJson;
      if (convo.lastMessage is UConvoMessageViewMessageView) {
        final lastMessage =
            (convo.lastMessage as UConvoMessageViewMessageView).data;
        lastMessageJson = {
          'id': lastMessage.id,
          'rev': lastMessage.rev,
          'text': lastMessage.text,
          'sender': {
            'did': lastMessage.sender.did,
          },
          'sentAt': lastMessage.sentAt.toIso8601String(),
          // Add other fields as needed
        };

        // Check and insert the last message
        await checkAndInsertMessageATProto(lastMessage);
      }

      // Insert or update the chat list entry
      await into(chatList).insert(
        ChatListCompanion.insert(
          id: convo.id,
          rev: convo.rev,
          members: json.encode(membersJson),
          lastMessage: json.encode(lastMessageJson ?? {}),
          muted: Value(convo.muted),
          hidden: const Value(false),
          unreadCount: Value(convo.unreadCount),
          lastUpdated: DateTime.now(),
        ),
        mode: InsertMode.insertOrReplace,
      );

      // Insert message list messages
      if (lastMessageJson != null) {
        into(chatListMessages).insert(ChatListMessagesCompanion.insert(
          chatId: lastMessageJson['id'],
          chatListId: convo.id,
        ));
      }
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = io.File(p.join(dbFolder.path, 'db.sqlite'));

    if (io.Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
