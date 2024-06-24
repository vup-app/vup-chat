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
  Future<void> checkAndInsertMessageATProto(
      MessageView message, String roomID) async {
    final Message? messageExists = await (select(messages)
          ..where((tbl) => tbl.id.equals(message.id)))
        .getSingleOrNull();

    // TODO: Add "sending" notification
    final _ = select(messages)
      ..where((tbl) => tbl.id.equals(message.id))
      ..where((tbl) => tbl.persisted.equals(false));

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
    }
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

        // Check and insert the last message
        await checkAndInsertMessageATProto(lastMessage, convo.id);
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
