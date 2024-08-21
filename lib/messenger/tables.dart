import 'package:drift/drift.dart';

class Senders extends Table {
  TextColumn get did => text()();
  TextColumn get displayName => text()();
  TextColumn get handle => text().withDefault(const Constant(""))();
  BlobColumn get avatar => blob().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get pubkey => text().nullable()(); // pubkey for signing shite

  @override
  Set<Column> get primaryKey => {did};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get bskyID => text().nullable()();
  TextColumn get revision => text().nullable()();
  TextColumn get message => text()();
  TextColumn get senderDid =>
      text().customConstraint('REFERENCES senders(did) NOT NULL')();
  TextColumn get replyTo =>
      text().nullable().customConstraint('REFERENCES messages(id)')();
  DateTimeColumn get sentAt => dateTime()();
  BoolColumn get persisted => boolean().withDefault(const Constant(false))();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  TextColumn get embed => text()(); // Serialized JSON
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  BoolColumn get encrypted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRooms extends Table {
  // TODO: Move chatroom ID away from ATProto
  TextColumn get id => text()();
  TextColumn get roomName => text()();
  TextColumn get mlsChatID => text().nullable()();
  TextColumn get rev => text()();
  TextColumn get members => text()(); // Serialized JSON
  TextColumn get lastMessage => text()(); // Serialized JSON

  /// Notification Level:
  /// First: Call level
  /// Second: Message level
  /// Options: [disable, silent, normal]
  /// Ex: silent-normal -> Silenced calls & normal text
  TextColumn get notificationLevel =>
      text().withDefault(const Constant("normal-normal"))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();
  BlobColumn get avatar => blob().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRoomMessages extends Table {
  TextColumn get chatId =>
      text().customConstraint('REFERENCES messages(id) NOT NULL')();
  TextColumn get chatRoomId =>
      text().customConstraint('REFERENCES chat_rooms(id) NOT NULL')();

  @override
  Set<Column> get primaryKey => {chatId, chatRoomId};
}
