import 'dart:convert';

import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:drift/drift.dart';

import 'connections/connection.dart' as impl;
import 'tables.dart';

part 'database.g.dart';

// And here are all the function defintions
@DriftDatabase(tables: [Senders, Content, Messages, ChatRoom, ChatRoomMessages])
class MessageDatabase extends _$MessageDatabase {
  MessageDatabase() : super(impl.connect());

  MessageDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  // Searches DB for contacts

  // Searches DB for messages
  Future<List<Message>> searchMessages(String q, String? chatID) async {
    final query = select(messages).join([
      innerJoin(
          chatRoomMessages, chatRoomMessages.chatId.equalsExp(messages.id)),
    ])
      ..where(messages.message.like('%$q%'));

    if (chatID != null) {
      // Case 1: Search for ALL messages undeer specific chat ID
      query.where(chatRoomMessages.chatRoomId.equals(chatID));
    } else {
      // Case 2: Search for ONE message for each chat ID
      final subQuery = select(chatRoomMessages).join([
        innerJoin(messages, messages.id.equalsExp(chatRoomMessages.chatId)),
      ])
        ..groupBy([chatRoomMessages.chatRoomId])
        ..where(messages.message.like('%$q%'));

      final distinctChatRoomIds = await subQuery
          .map((row) => row.readTable(chatRoomMessages).chatRoomId)
          .get();

      query.where(chatRoomMessages.chatRoomId.isIn(distinctChatRoomIds));
    }
    return query.map((row) => row.readTable(messages)).get();
  }

  // Pull from chatRoomMessages table to find chatRoomID from messageID
  Future<String?> getChatRoomIdFromMessageId(String messageID) async {
    final query = select(chatRoomMessages)
      ..where((tbl) => tbl.chatId.equals(messageID));

    final result = await query.getSingleOrNull();
    return result?.chatRoomId;
  }

  // Grab the chat room associated with chatID
  Future<ChatRoomData?> getChatRoomFromChatID(String chatID) async {
    final query = select(chatRoom)..where((t) => t.id.equals(chatID));
    final ChatRoomData? result = await query.getSingleOrNull();
    return result;
  }

  // Get Sender object from did
  Future<Sender?> getSenderByDID(String did) {
    return (select(senders)..where((t) => t.did.equals(did))).getSingleOrNull();
  }

  // Stream to watch messages for a list
  Stream<List<Message>> watchChatForMessage(String chatID) {
    final query = select(messages).join([
      innerJoin(
          chatRoomMessages, chatRoomMessages.chatId.equalsExp(messages.id)),
    ])
      ..where(chatRoomMessages.chatRoomId.equals(chatID))
      ..orderBy([
        OrderingTerm(expression: messages.sentAt, mode: OrderingMode.desc),
      ]);

    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(messages)).toList());
  }

  // Stream to watch the most recent message in each chat room
  Stream<List<ChatRoomData>> watchChatRooms() {
    final query = select(chatRoom).join([
      innerJoin(
        chatRoomMessages,
        chatRoomMessages.chatRoomId.equalsExp(chatRoom.id),
      ),
    ])
      ..groupBy([chatRoom.id]) // Group by chat room ID
      ..orderBy([
        OrderingTerm.desc(
            chatRoom.lastUpdated), // Order by lastUpdated descending
      ]);
    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(chatRoom)).toList());
  }

  // Check if a sender exists and insert if not
  Future<void> checkAndInsertSenderATProto(Sender sender) async {
    final senderExists = await (select(senders)
          ..where((tbl) => tbl.did.equals(sender.did)))
        .getSingleOrNull();
    if (senderExists == null) {
      into(senders).insert(SendersCompanion.insert(
        did: sender.did,
        displayName: sender.displayName,
        avatarUrl: Value(sender.avatarUrl),
      ));
    } else {
      if (senderExists.displayName != sender.displayName) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(
          did: Value(senderExists.did),
          displayName: Value(sender.displayName),
          avatarUrl: Value(senderExists.avatarUrl),
        ));
      }
      if (senderExists.avatarUrl != sender.avatarUrl) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(
          did: Value(senderExists.did),
          displayName: Value(senderExists.displayName),
          avatarUrl: Value(sender.avatarUrl),
        ));
      }
    }
  }

  // Check if a message exists and insert if not
  Future<void> checkAndInsertMessageATProto(
      MessageView message, String roomID, bool persisted, Sender sender) async {
    final Message? messageExists = await (select(messages)
          ..where((tbl) => tbl.id.equals(message.id)))
        .getSingleOrNull();

    if (messageExists == null) {
      // Insert updated sender
      checkAndInsertSenderATProto(sender);

      // Insert the message
      await into(messages).insert(MessagesCompanion.insert(
        id: message.id,
        revision: message.rev,
        message: message.text,
        senderDid: message.sender.did,
        replyTo: const Value(null), // ATProto doesn't support this
        sentAt: message.sentAt,
        persisted: Value(persisted), // Set the initial persisted state
      ));

      // Check if the chatRoomMessage already exists
      final chatRoomMessageExists = await (select(chatRoomMessages)
            ..where((tbl) =>
                tbl.chatId.equals(message.id) & tbl.chatRoomId.equals(roomID)))
          .getSingleOrNull();

      if (chatRoomMessageExists == null) {
        // Insert into ChatRoomMessages to create the relationship
        await into(chatRoomMessages).insert(ChatRoomMessage(
          chatId: message.id,
          chatRoomId: roomID,
        ));
      }

      _updateChatRoomLastMessage(roomID, message);
    } else if (messageExists.persisted == false && persisted) {
      // Message exists but is not persisted, update the persisted field
      await (update(messages)..where((tbl) => tbl.id.equals(message.id)))
          .write(MessagesCompanion(
        persisted: Value(persisted),
      ));
    }
  }

  Future<void> _updateChatRoomLastMessage(
      String roomID, MessageView message) async {
    final lastMessageJson = json.encode({
      'id': message.id,
      'rev': message.rev,
      'text': message.text,
      'sender': {
        'did': message.sender.did,
      },
      'sentAt': message.sentAt.toIso8601String(),
      // Add other fields as needed
    });

    await (update(chatRoom)..where((tbl) => tbl.id.equals(roomID)))
        .write(ChatRoomCompanion(
      lastMessage: Value(lastMessageJson),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  // Check if a message list exists and insert if not
  Future<void> checkAndInsertChatRoom(ConvoView convo) async {
    final chatRoomExists = await (select(chatRoom)
          ..where((tbl) => tbl.id.equals(convo.id)))
        .getSingleOrNull();

    if (chatRoomExists == null) {
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

        final Sender sender = Sender(
            did: convo.members.last.did,
            displayName: convo.members.last.handle,
            avatarUrl: convo.members.last.avatar);

        // Check and insert the last message
        await checkAndInsertMessageATProto(lastMessage, convo.id, true, sender);
      }

      // Insert or update the chat list entry
      await into(chatRoom).insert(
        ChatRoomCompanion.insert(
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
        final chatRoomMessageExists = await (select(chatRoomMessages)
              ..where((tbl) =>
                  tbl.chatId.equals(lastMessageJson!['id']) &
                  tbl.chatRoomId.equals(convo.id)))
            .getSingleOrNull();
        if (chatRoomMessageExists == null) {
          into(chatRoomMessages).insert(ChatRoomMessagesCompanion.insert(
            chatId: lastMessageJson['id'],
            chatRoomId: convo.id,
          ));
        }
      }
    }
  }
}
