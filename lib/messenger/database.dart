import 'dart:convert';

import 'package:bluesky/bluesky_chat.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:vup_chat/definitions/s5_embed.dart';
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

  // Database migrations!
  @override
  int get schemaVersion => 5; // bump because the tables have changed.

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(senders, senders.avatarUrl);
          await m.addColumn(chatRooms, chatRooms.avatarUrl);
        }
        if (from < 3) {
          await m.addColumn(senders, senders.handle);
          await m.addColumn(messages, messages.encrypted);
          await m.addColumn(chatRooms, chatRooms.mlsChatID);
        }
        if (from < 4) {
          await m.addColumn(senders, senders.pubkey);
        }
        if (from < 5) {
          await m.addColumn(messages, messages.mlsID);
        }
      },
    );
  }

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

  // Change Notification Level
  Future<void> setNotificationLevel(
      String chatID, String? callLevel, String? messageLevel) async {
    // Check if there are inputs set to the function
    final bool validateNewCallLevel = (callLevel != null &&
        (callLevel == "disable" ||
            callLevel == "silent" ||
            callLevel == "normal"));
    final bool validateNewMessageLevel = (messageLevel != null &&
        (messageLevel == "disable" ||
            messageLevel == "silent" ||
            messageLevel == "normal"));
    if (validateNewCallLevel || validateNewMessageLevel) {
      // Get the current chatRoom and check it's notification level
      final ChatRoom? chatRoom = await (select(chatRooms)
            ..where((t) => t.id.equals(chatID)))
          .getSingleOrNull();
      if (chatRoom != null) {
        // Now construct the new notification level string
        final List<String> splitNotificationLevel =
            chatRoom.notificationLevel.split("-");
        late String newNoticiationLevel;
        if (validateNewCallLevel && validateNewMessageLevel) {
          newNoticiationLevel = "$callLevel-$messageLevel";
        } else if (validateNewCallLevel && !validateNewMessageLevel) {
          newNoticiationLevel = "$callLevel-${splitNotificationLevel[1]}";
        } else if (!validateNewCallLevel && validateNewMessageLevel) {
          newNoticiationLevel = "${splitNotificationLevel[0]}-$messageLevel";
        } else {
          newNoticiationLevel =
              "${splitNotificationLevel[0]}-${splitNotificationLevel[1]}";
        }
        // And update the chatRoom
        await (update(chatRooms)..where((t) => t.id.equals(chatID))).write(
            ChatRoomsCompanion(notificationLevel: Value(newNoticiationLevel)));
      }
    }
  }

  // Toggle Hidden
  Future<void> chatHiddenHelper(String chatID, String mode) async {
    // 1: hide
    // 2: unhide
    // 3: toggle
    switch (mode) {
      case "hide":
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(hidden: Value(true)));
        }
      case "unhide":
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(hidden: Value(false)));
        }
      case "toggle-hide":
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

  // Toggle Pin
  Future<void> chatPinHelper(String chatID, String mode) async {
    // 1: pin
    // 2: unpin
    // 3: toggle
    switch (mode) {
      case "pin":
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(pinned: Value(true)));
        }
      case "unpin":
        {
          await (update(chatRooms)..where((t) => t.id.equals(chatID)))
              .write(const ChatRoomsCompanion(pinned: Value(false)));
        }
      case "toggle-pin":
        {
          bool? curPinned = await isPinned(chatID);
          if (curPinned != null) {
            // Inverter ternary switch (probably works)
            await (update(chatRooms)..where((t) => t.id.equals(chatID))).write(
                ChatRoomsCompanion(pinned: Value(curPinned ? false : true)));
          }
        }
      default:
        return; // this should never be reached
    }
  }

  // Toggle Star
  Future<void> msgStarHelper(String msgID, String mode) async {
    // 1: star
    // 2: unstar
    // 3: toggle
    switch (mode) {
      case "star":
        {
          await (update(messages)..where((t) => t.id.equals(msgID)))
              .write(const MessagesCompanion(starred: Value(true)));
        }
      case "unstar":
        {
          await (update(messages)..where((t) => t.id.equals(msgID)))
              .write(const MessagesCompanion(starred: Value(false)));
        }
      case "toggle-star":
        {
          bool? curStarred = await isStarred(msgID);
          if (curStarred != null) {
            // Inverter ternary switch (probably works)
            await (update(messages)..where((t) => t.id.equals(msgID))).write(
                MessagesCompanion(starred: Value(curStarred ? false : true)));
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

  // Checks if pinned currently
  Future<bool?> isPinned(String chatID) async {
    final query = select(chatRooms)..where((t) => t.id.equals(chatID));
    final res = await query.getSingleOrNull();
    if (res != null) {
      return res.pinned;
    } else {
      return null;
    }
  }

  // Checks if starred currently
  Future<bool?> isStarred(String msgID) async {
    final query = select(messages)..where((t) => t.id.equals(msgID));
    final res = await query.getSingleOrNull();
    if (res != null) {
      return res.starred;
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

  // Pull from chatRoomMessages table to find chatRoomID from messageID
  Future<String?> getChatRoomIDFromMLSGroupID(String mlsGroupID) async {
    final query = select(chatRooms)
      ..where((tbl) => tbl.mlsChatID.equals(mlsGroupID));

    final result = await query.getSingleOrNull();
    return result?.id;
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

  // Stream to watch messages which are starred
  Stream<List<Message>> watchChatForMessageStarred(String chatID) {
    final query = select(messages).join([
      innerJoin(
          chatRoomMessages, chatRoomMessages.chatId.equalsExp(messages.id)),
    ])
      ..where(chatRoomMessages.chatRoomId.equals(chatID))
      ..where(messages.starred.equals(true))
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
        (u) => OrderingTerm(expression: u.pinned, mode: OrderingMode.desc),
        (u) => OrderingTerm(expression: u.lastUpdated, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // Streams to watch for changes in a chatRoom itself
  Stream<ChatRoom> watchChatRoom(String chatID) {
    final query = select(chatRooms)..where((t) => t.id.equals(chatID));
    return query.watchSingle();
  }

  // Check if a sender exists and insert if not
  Future<void> insertOrUpdateSender(Sender sender) async {
    final senderExists = await (select(senders)
          ..where((tbl) => tbl.did.equals(sender.did)))
        .getSingleOrNull();

    if (senderExists == null) {
      into(senders).insert(SendersCompanion.insert(
          did: sender.did,
          displayName: sender.displayName,
          handle: Value(sender.handle),
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
      if (senderExists.handle != sender.handle) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(handle: Value(sender.handle)));
      }
      if (senderExists.pubkey != sender.pubkey) {
        await (update(senders)..where((tbl) => tbl.did.equals(sender.did)))
            .write(SendersCompanion(pubkey: Value(sender.pubkey)));
      }
    }
  }

  // DOES NOT check if message exists, returns message UUID
  Future<String> insertMessageLocal(String message, String roomID,
      Sender sender, S5Embed? embed, bool encrypted, String? mlsID) async {
    String id = const Uuid().v4();
    await into(messages).insert(MessagesCompanion.insert(
      id: id,
      message: message,
      senderDid: sender.did,
      sentAt: DateTime.now(),
      embed: embed?.toJson().toString() ?? "",
      encrypted: Value(encrypted),
      persisted: encrypted ? const Value(true) : const Value(false),
      mlsID: Value(mlsID),
    ));

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
      insertOrUpdateSender(sender);
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

      final Message msg = Message(
          id: messageID,
          message: message.text,
          senderDid: message.sender.did,
          sentAt: message.sentAt,
          persisted: persisted,
          read: false,
          embed: "",
          starred: false,
          encrypted: false);

      updateChatRoomsLastMessage(roomID, msg);

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
  Future<void> updateChatRoomsLastMessage(
      String roomID, Message message) async {
    // first gotta check if there already is a newer message
    final croom = await (select(chatRooms)..where((t) => t.id.equals(roomID)))
        .getSingleOrNull();
    if (croom != null && croom.lastUpdated.isBefore(message.sentAt)) {
      // Then if it's newer update it
      final lastMessageJson = json.encode({
        'id': message.id,
        'text': message.message,
        'sender': {
          'did': message.senderDid,
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

      // Grab the sender that isn't you
      final ProfileViewBasic otherMember =
          convo.members.firstWhere((element) => element.did != did);

      // This section pulls avatar bytes based on platform
      Uint8List? avatarBytes;
      // Grabs the avatar if not on web
      if (!kIsWeb) {
        try {
          http.Response response = await http.get(
            Uri.parse(otherMember.avatar!),
          );
          avatarBytes = response.bodyBytes;
        } catch (e) {
          logger.e(e);
        }
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

        // Insert or update the chat list entry
        if (chatRoomExists == null ||
            chatRoomExists.lastUpdated.isBefore(lastMessage.sentAt)) {
          await into(chatRooms).insert(
            ChatRoomsCompanion.insert(
              id: convo.id,
              roomName: (otherMember.displayName == null ||
                      otherMember.displayName!.isEmpty)
                  ? otherMember.handle
                  : otherMember
                      .displayName!, // TODO: Make this dynamic for group chats
              rev: convo.rev,
              members: json.encode(members),
              lastMessage: json.encode(lastMessageJson),
              hidden: const Value(false),
              unreadCount: Value(convo.unreadCount),
              lastUpdated: lastMessage.sentAt,
              avatar: Value(avatarBytes),
              avatarUrl: Value(otherMember.avatar),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      } else {
        await into(chatRooms).insert(
          ChatRoomsCompanion.insert(
            id: convo.id,
            roomName: (otherMember.displayName == null ||
                    otherMember.displayName!.isEmpty)
                ? otherMember.handle
                : otherMember
                    .displayName!, // TODO: Make this dynamic for group chats
            rev: convo.rev,
            members: json.encode(members),
            lastMessage: chatRoomExists?.lastMessage ?? "",
            hidden: const Value(false),
            unreadCount: Value(convo.unreadCount),
            lastUpdated: chatRoomExists?.lastUpdated ?? DateTime(0),
            avatar: Value(avatarBytes),
            avatarUrl: Value(otherMember.avatar),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    }
  }

  // Updates chatRoom based on new contents
  Future<void> updateChatRoom(ChatRoom chatRoom) async {
    final ChatRoom? chatRoomOld = await (select(chatRooms)
          ..where((tbl) => tbl.id.equals(chatRoom.id)))
        .getSingleOrNull();
    if (chatRoomOld != null) {
      // just implementing updating mlsChatID for now, can add more later
      if (chatRoomOld.mlsChatID != chatRoom.mlsChatID) {
        await (update(chatRooms)..where((t) => t.id.equals(chatRoom.id)))
            .write(ChatRoomsCompanion(mlsChatID: Value(chatRoom.mlsChatID)));
      }
      // Update other stuff later
    }
  }

  // Get message from local ID
  Future<Message?> getMessageFromLocalID(String messageID) async {
    final query = select(messages)..where((t) => t.id.equals(messageID));
    return query.getSingleOrNull();
  }

  // Get message from MLS ID
  Future<Message?> getMessageFromMLSID(String mlsID) async {
    final query = select(messages)..where((t) => t.mlsID.equals(mlsID));
    return query.getSingleOrNull();
  }

  Future<void> deleteLocalMessage(String messageID) async {
    await (delete(messages)..where((t) => t.id.equals(messageID))).go();
  }
}
