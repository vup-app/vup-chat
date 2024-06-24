import 'package:drift/drift.dart';

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
  BoolColumn get persisted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRoom extends Table {
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

class ChatRoomMessages extends Table {
  TextColumn get chatId =>
      text().customConstraint('REFERENCES messages(id) NOT NULL')();
  TextColumn get chatRoomId =>
      text().customConstraint('REFERENCES chat_room(id) NOT NULL')();

  @override
  Set<Column> get primaryKey => {chatId, chatRoomId};
}
