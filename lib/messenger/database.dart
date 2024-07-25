import 'dart:convert';

import 'package:bluesky/bluesky_chat.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:vup_chat/definitions/s5embed.dart';
import 'package:http/http.dart' as http;
import 'package:vup_chat/main.dart';

import 'connections/connection.dart' as impl;
import 'tables.dart';

part 'database.g.dart';

// And here are all the function defintions
@DriftDatabase(tables: [Senders, Messages, ChatRooms, ChatRoomMessages])
class MessageDatabase extends _$MessageDatabase {
  MessageDatabase() : super(impl.connect());

  MessageDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  // Searches DB for group names
  Future<List<ChatRoom>> searchChatRooms(String q) async {
    final query = select(chatRooms)..where((t) => t.roomName.like('%$q%'));
    return query.get();
  }

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

      final distinctChatRoomsIds = await subQuery
          .map((row) => row.readTable(chatRoomMessages).chatRoomId)
          .get();

      query.where(chatRoomMessages.chatRoomId.isIn(distinctChatRoomsIds));
    }
    return query.map((row) => row.readTable(messages)).get();
  }

  Future<void> changeRoomName(String chatID, String newRoomName) async {
    await (update(chatRooms)..where((t) => t.id.equals(chatID)))
        .write(ChatRoomsCompanion(roomName: Value(newRoomName)));
  }

  // Toggle Mute
  Future<void> chatMuteHelper(String chatID, int mode) async {
    // 1: mute
    // 2: unmute
    // 3: toggle
    switch (mode) {
      case 1:
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(muted: Value(true)));
        }
      case 2:
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(muted: Value(false)));
        }
      case 3:
        {
          bool? curMuted = await isMuted(chatID);
          if (curMuted != null) {
            // Inverter ternary switch (probably works)
            await (update(chatRooms)..where((t) => t.id.equals(chatID))).write(
                ChatRoomsCompanion(muted: Value(curMuted ? false : true)));
          }
        }
      default:
        return; // this should never be reached
    }
  }

  // Checks if muted currently
  Future<bool?> isMuted(String chatID) async {
    final query = select(chatRooms)..where((t) => t.id.equals(chatID));
    final res = await query.getSingleOrNull();
    if (res != null) {
      return res.muted;
    } else {
      return null;
    }
  }

  // Toggle Hidden
  Future<void> chatHiddenHelper(String chatID, int mode) async {
    // 1: hide
    // 2: unhide
    // 3: toggle
    switch (mode) {
      case 1:
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(hidden: Value(true)));
        }
      case 2:
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(hidden: Value(false)));
        }
      case 3:
        {
          bool? curHidden = await isHidden(chatID);
          if (curHidden != null) {
            // Inverter ternary switch (probably works)
            await (update(chatRooms)..where((t) => t.id.equals(chatID))).write(
                ChatRoomsCompanion(hidden: Value(curHidden ? false : true)));
          }
        }
      default:
        return; // this should never be reached
    }
  }

  // Checks if muted currently
  Future<bool?> isHidden(String chatID) async {
    final query = select(chatRooms)..where((t) => t.id.equals(chatID));
    final res = await query.getSingleOrNull();
    if (res != null) {
      return res.hidden;
    } else {
      return null;
    }
  }

  // Pull from chatRoomMessages table to find chatRoomID from messageID
  Future<String?> getChatRoomsIdFromMessageId(String messageID) async {
    final query = select(chatRoomMessages)
      ..where((tbl) => tbl.chatId.equals(messageID));

    final result = await query.getSingleOrNull();
    return result?.chatRoomId;
  }

  // Grab the chat room associated with chatID
  Future<ChatRoom?> getChatRoomFromChatID(String chatID) async {
    final query = select(chatRooms)..where((t) => t.id.equals(chatID));
    final ChatRoom? result = await query.getSingleOrNull();
    return result;
  }

  Future<String?> getMessageIDFromBskyValues(
      String bskyChatID, String bskyMessageID) async {
    // Select the message ID from the Messages table where bskyID matches the provided bskyMessageID
    // and join with the ChatRoomMessages table where the chatRoomId matches the provided bskyChatID
    final query = select(messages).join([
      innerJoin(
        chatRoomMessages,
        chatRoomMessages.chatId.equalsExp(messages.id),
      )
    ])
      ..where(messages.bskyID.equals(bskyMessageID) &
          chatRoomMessages.chatRoomId.equals(bskyChatID));

    // Execute the query and get the result
    final result = await query.getSingleOrNull();

    // Return the message ID if found, otherwise return null
    return result?.readTable(messages).id;
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
  Stream<List<ChatRoom>> watchChatRooms() {
    final query = select(chatRooms)
      ..orderBy([
        (u) => OrderingTerm(expression: u.lastUpdated, mode: OrderingMode.desc),
      ]);
    return query.watch();
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
          avatar: Value(sender.avatar),
          description: Value(sender.description)));
    } else {
      if (senderExists.displayName != sender.displayName) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(
                SendersCompanion(displayName: Value(senderExists.displayName)));
      }
      if (senderExists.description != sender.description) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(description: Value(sender.description)));
      }
      if (senderExists.avatar != sender.avatar) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(avatar: Value(sender.avatar)));
      }
    }
  }

  // DOES NOT check if message exists, returns message UUID
  Future<String> insertMessageLocal(
      String message, String roomID, Sender sender, S5Embed? embed) async {
    String id = const Uuid().v4();
    await into(messages).insert(MessagesCompanion.insert(
        id: id,
        message: message,
        senderDid: did ?? "",
        sentAt: DateTime.now(),
        embed: embed?.toJson().toString() ?? ""));

    // Check if the chatRoomMessage already exists
    final chatRoomMessageExists = await (select(chatRoomMessages)
          ..where(
              (tbl) => tbl.chatId.equals(id) & tbl.chatRoomId.equals(roomID)))
        .getSingleOrNull();

    if (chatRoomMessageExists == null) {
      // Insert into ChatRoomsMessages to create the relationship
      await into(chatRoomMessages).insert(ChatRoomMessage(
        chatId: id,
        chatRoomId: roomID,
      ));
    }

    return id;
  }

  // Check if a message exists and insert if not
  // Return: true -> new message, should notify
  // Return: false -> message already exists, don't notify
  Future<bool> checkAndInsertMessageATProto(
      String messageID,
      MessageView message,
      String roomID,
      bool persisted,
      Sender sender,
      S5Embed? embed) async {
    final Message? messageExists = await (select(messages)
          ..where((tbl) => tbl.id.equals(messageID)))
        .getSingleOrNull();

    if (messageExists == null || messageExists.bskyID == null) {
      // Insert updated sender
      checkAndInsertSenderATProto(sender);
      // Insert the message
      await into(messages).insert(
          MessagesCompanion.insert(
            id: messageID,
            bskyID: Value(message.id),
            revision: Value(message.rev),
            message: message.text,
            senderDid: message.sender.did,
            replyTo: const Value(null), // ATProto doesn't support this
            sentAt: message.sentAt,
            persisted: Value(persisted), // Set the initial persisted state
            read: const Value(false),
            embed: message.embed?.toJson().toString() ?? "",
          ),
          mode: InsertMode.insertOrReplace);

      // Check if the chatRoomMessage already exists
      final chatRoomMessageExists = await (select(chatRoomMessages)
            ..where((tbl) =>
                tbl.chatId.equals(messageID) & tbl.chatRoomId.equals(roomID)))
          .getSingleOrNull();

      if (chatRoomMessageExists == null) {
        // Insert into ChatRoomsMessages to create the relationship
        await into(chatRoomMessages).insert(ChatRoomMessage(
          chatId: messageID,
          chatRoomId: roomID,
        ));
      }

      _updateChatRoomsLastMessage(roomID, message);

      return true;
    }
    if (messageExists.persisted == false && persisted) {
      // Message exists but is not persisted, update the persisted field
      await (update(messages)..where((tbl) => tbl.id.equals(messageID)))
          .write(MessagesCompanion(
        persisted: Value(persisted),
      ));
    }
    return false;
  }

  // Updates the chatroom last message
  Future<void> _updateChatRoomsLastMessage(
      String roomID, MessageView message) async {
    // first gotta check if there already is a newer message
    final croom = await (select(chatRooms)..where((t) => t.id.equals(roomID)))
        .getSingleOrNull();
    if (croom != null && croom.lastUpdated.isBefore(message.sentAt)) {
      // Then if it's newer update it
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

      await (update(chatRooms)..where((tbl) => tbl.id.equals(roomID)))
          .write(ChatRoomsCompanion(
        lastMessage: Value(lastMessageJson),
        lastUpdated: Value(message.sentAt),
      ));
    }
  }

  // Check if a message list exists and insert if not
  Future<void> checkAndInsertChatRoom(ConvoView convo) async {
    final chatRoomExists = await (select(chatRooms)
          ..where((tbl) => tbl.id.equals(convo.id)))
        .getSingleOrNull();

    if (chatRoomExists == null) {
      // Pull sender dids
      final List<String> members = convo.members.map((obj) => obj.did).toList();

      Uint8List? avatarBytes;
      try {
        http.Response response = await http.get(
          Uri.parse(convo.members.last.avatar!),
        );
        avatarBytes = response.bodyBytes;
      } catch (e) {
        logger.d(e);
      }

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

        // final Sender sender = Sender(
        //   did: convo.members.last.did,
        //   displayName:
        //       convo.members.last.displayName ?? convo.members.last.handle,
        //   avatar: avatarBytes,
        // );

        // // Check and insert the last message
        // await checkAndInsertMessageATProto(
        //     "", lastMessage, convo.id, true, sender, null);

        // Insert or update the chat list entry
        if (chatRoomExists == null ||
            chatRoomExists.lastUpdated.isBefore(lastMessage.sentAt)) {
          await into(chatRooms).insert(
            ChatRoomsCompanion.insert(
              id: convo.id,
              roomName: convo.members.last.displayName ??
                  convo.members.last
                      .handle, // TODO: Make this dynamic for group chats
              rev: convo.rev,
              members: json.encode(members),
              lastMessage: json.encode(lastMessageJson),
              muted: Value(convo.muted),
              hidden: const Value(false),
              unreadCount: Value(convo.unreadCount),
              lastUpdated: lastMessage.sentAt,
              avatar: Value(avatarBytes),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      } else {
        await into(chatRooms).insert(
          ChatRoomsCompanion.insert(
              id: convo.id,
              roomName: convo.members.last.displayName ??
                  convo.members.last
                      .handle, // TODO: Make this dynamic for group chats
              rev: convo.rev,
              members: json.encode(members),
              lastMessage: chatRoomExists?.lastMessage ?? "",
              muted: Value(convo.muted),
              hidden: const Value(false),
              unreadCount: Value(convo.unreadCount),
              lastUpdated: chatRoomExists?.lastUpdated ?? DateTime(0),
              avatar: Value(avatarBytes)),
          mode: InsertMode.insertOrReplace,
        );
      }
    }
  }

  // Get message from local ID
  Future<Message?> getMessageFromLocalID(String messageID) async {
    final query = select(messages)..where((t) => t.id.equals(messageID));
    return query.getSingleOrNull();
  }
}
