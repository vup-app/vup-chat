import 'package:drift/drift.dart';

// TODO: Move avatar to embedded photo file to speed up load times
class Senders extends Table {
  TextColumn get did => text()();
  TextColumn get displayName => text()();
  BlobColumn get avatar => blob().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {did};
}

class Messages extends Table {
  // TODO: Move message ID away from ATProto
  TextColumn get id => text()();
  TextColumn get revision => text()();
  TextColumn get message => text()();
  TextColumn get senderDid =>
      text().customConstraint('REFERENCES senders(did) NOT NULL')();
  TextColumn get replyTo =>
      text().nullable().customConstraint('REFERENCES messages(id)')();
  DateTimeColumn get sentAt => dateTime()();
  BoolColumn get persisted => boolean().withDefault(const Constant(false))();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  TextColumn get embed => text()(); // Serialized JSON

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRoom extends Table {
  // TODO: Move chatroom ID away from ATProto
  TextColumn get id => text()();
  TextColumn get roomName => text()();
  TextColumn get rev => text()();
  TextColumn get members => text()(); // Serialized JSON
  TextColumn get lastMessage => text()(); // Serialized JSON
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();
  BlobColumn get avatar => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRoomMessages extends Table {
  TextColumn get chatId =>
      text().customConstraint('REFERENCES messages(id) NOT NULL')();
  TextColumn get chatRoomId =>
      text().customConstraint('REFERENCES chat_room(id) NOT NULL')();

  @override
  Set<Column> get primaryKey => {chatId, chatRoomId};
}
