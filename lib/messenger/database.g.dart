// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SendersTable extends Senders with TableInfo<$SendersTable, Sender> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _didMeta = const VerificationMeta('did');
  @override
  late final GeneratedColumn<String> did = GeneratedColumn<String>(
      'did', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [did, displayName, avatarUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'senders';
  @override
  VerificationContext validateIntegrity(Insertable<Sender> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('did')) {
      context.handle(
          _didMeta, did.isAcceptableOrUnknown(data['did']!, _didMeta));
    } else if (isInserting) {
      context.missing(_didMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {did};
  @override
  Sender map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sender(
      did: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}did'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
    );
  }

  @override
  $SendersTable createAlias(String alias) {
    return $SendersTable(attachedDatabase, alias);
  }
}

class Sender extends DataClass implements Insertable<Sender> {
  final String did;
  final String displayName;
  final String? avatarUrl;
  const Sender({required this.did, required this.displayName, this.avatarUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['did'] = Variable<String>(did);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    return map;
  }

  SendersCompanion toCompanion(bool nullToAbsent) {
    return SendersCompanion(
      did: Value(did),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
    );
  }

  factory Sender.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sender(
      did: serializer.fromJson<String>(json['did']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'did': serializer.toJson<String>(did),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
    };
  }

  Sender copyWith(
          {String? did,
          String? displayName,
          Value<String?> avatarUrl = const Value.absent()}) =>
      Sender(
        did: did ?? this.did,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
      );
  @override
  String toString() {
    return (StringBuffer('Sender(')
          ..write('did: $did, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(did, displayName, avatarUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sender &&
          other.did == this.did &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl);
}

class SendersCompanion extends UpdateCompanion<Sender> {
  final Value<String> did;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<int> rowid;
  const SendersCompanion({
    this.did = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SendersCompanion.insert({
    required String did,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : did = Value(did),
        displayName = Value(displayName);
  static Insertable<Sender> custom({
    Expression<String>? did,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (did != null) 'did': did,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SendersCompanion copyWith(
      {Value<String>? did,
      Value<String>? displayName,
      Value<String?>? avatarUrl,
      Value<int>? rowid}) {
    return SendersCompanion(
      did: did ?? this.did,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (did.present) {
      map['did'] = Variable<String>(did.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SendersCompanion(')
          ..write('did: $did, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _revisionMeta =
      const VerificationMeta('revision');
  @override
  late final GeneratedColumn<String> revision = GeneratedColumn<String>(
      'revision', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderDidMeta =
      const VerificationMeta('senderDid');
  @override
  late final GeneratedColumn<String> senderDid = GeneratedColumn<String>(
      'sender_did', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES senders(did) NOT NULL');
  static const VerificationMeta _replyToMeta =
      const VerificationMeta('replyTo');
  @override
  late final GeneratedColumn<String> replyTo = GeneratedColumn<String>(
      'reply_to', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES messages(id)');
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _persistedMeta =
      const VerificationMeta('persisted');
  @override
  late final GeneratedColumn<bool> persisted = GeneratedColumn<bool>(
      'persisted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("persisted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _embedMeta = const VerificationMeta('embed');
  @override
  late final GeneratedColumn<String> embed = GeneratedColumn<String>(
      'embed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        revision,
        message,
        senderDid,
        replyTo,
        sentAt,
        persisted,
        read,
        embed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(_revisionMeta,
          revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta));
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('sender_did')) {
      context.handle(_senderDidMeta,
          senderDid.isAcceptableOrUnknown(data['sender_did']!, _senderDidMeta));
    } else if (isInserting) {
      context.missing(_senderDidMeta);
    }
    if (data.containsKey('reply_to')) {
      context.handle(_replyToMeta,
          replyTo.isAcceptableOrUnknown(data['reply_to']!, _replyToMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('persisted')) {
      context.handle(_persistedMeta,
          persisted.isAcceptableOrUnknown(data['persisted']!, _persistedMeta));
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    if (data.containsKey('embed')) {
      context.handle(
          _embedMeta, embed.isAcceptableOrUnknown(data['embed']!, _embedMeta));
    } else if (isInserting) {
      context.missing(_embedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      revision: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}revision'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      senderDid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_did'])!,
      replyTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to']),
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
      persisted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}persisted'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      embed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}embed'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String revision;
  final String message;
  final String senderDid;
  final String? replyTo;
  final DateTime sentAt;
  final bool persisted;
  final bool read;
  final String embed;
  const Message(
      {required this.id,
      required this.revision,
      required this.message,
      required this.senderDid,
      this.replyTo,
      required this.sentAt,
      required this.persisted,
      required this.read,
      required this.embed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<String>(revision);
    map['message'] = Variable<String>(message);
    map['sender_did'] = Variable<String>(senderDid);
    if (!nullToAbsent || replyTo != null) {
      map['reply_to'] = Variable<String>(replyTo);
    }
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['persisted'] = Variable<bool>(persisted);
    map['read'] = Variable<bool>(read);
    map['embed'] = Variable<String>(embed);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      revision: Value(revision),
      message: Value(message),
      senderDid: Value(senderDid),
      replyTo: replyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(replyTo),
      sentAt: Value(sentAt),
      persisted: Value(persisted),
      read: Value(read),
      embed: Value(embed),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<String>(json['revision']),
      message: serializer.fromJson<String>(json['message']),
      senderDid: serializer.fromJson<String>(json['senderDid']),
      replyTo: serializer.fromJson<String?>(json['replyTo']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      persisted: serializer.fromJson<bool>(json['persisted']),
      read: serializer.fromJson<bool>(json['read']),
      embed: serializer.fromJson<String>(json['embed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<String>(revision),
      'message': serializer.toJson<String>(message),
      'senderDid': serializer.toJson<String>(senderDid),
      'replyTo': serializer.toJson<String?>(replyTo),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'persisted': serializer.toJson<bool>(persisted),
      'read': serializer.toJson<bool>(read),
      'embed': serializer.toJson<String>(embed),
    };
  }

  Message copyWith(
          {String? id,
          String? revision,
          String? message,
          String? senderDid,
          Value<String?> replyTo = const Value.absent(),
          DateTime? sentAt,
          bool? persisted,
          bool? read,
          String? embed}) =>
      Message(
        id: id ?? this.id,
        revision: revision ?? this.revision,
        message: message ?? this.message,
        senderDid: senderDid ?? this.senderDid,
        replyTo: replyTo.present ? replyTo.value : this.replyTo,
        sentAt: sentAt ?? this.sentAt,
        persisted: persisted ?? this.persisted,
        read: read ?? this.read,
        embed: embed ?? this.embed,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('message: $message, ')
          ..write('senderDid: $senderDid, ')
          ..write('replyTo: $replyTo, ')
          ..write('sentAt: $sentAt, ')
          ..write('persisted: $persisted, ')
          ..write('read: $read, ')
          ..write('embed: $embed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, revision, message, senderDid, replyTo,
      sentAt, persisted, read, embed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.message == this.message &&
          other.senderDid == this.senderDid &&
          other.replyTo == this.replyTo &&
          other.sentAt == this.sentAt &&
          other.persisted == this.persisted &&
          other.read == this.read &&
          other.embed == this.embed);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> revision;
  final Value<String> message;
  final Value<String> senderDid;
  final Value<String?> replyTo;
  final Value<DateTime> sentAt;
  final Value<bool> persisted;
  final Value<bool> read;
  final Value<String> embed;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.message = const Value.absent(),
    this.senderDid = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.persisted = const Value.absent(),
    this.read = const Value.absent(),
    this.embed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String revision,
    required String message,
    required String senderDid,
    this.replyTo = const Value.absent(),
    required DateTime sentAt,
    this.persisted = const Value.absent(),
    this.read = const Value.absent(),
    required String embed,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        revision = Value(revision),
        message = Value(message),
        senderDid = Value(senderDid),
        sentAt = Value(sentAt),
        embed = Value(embed);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? revision,
    Expression<String>? message,
    Expression<String>? senderDid,
    Expression<String>? replyTo,
    Expression<DateTime>? sentAt,
    Expression<bool>? persisted,
    Expression<bool>? read,
    Expression<String>? embed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (message != null) 'message': message,
      if (senderDid != null) 'sender_did': senderDid,
      if (replyTo != null) 'reply_to': replyTo,
      if (sentAt != null) 'sent_at': sentAt,
      if (persisted != null) 'persisted': persisted,
      if (read != null) 'read': read,
      if (embed != null) 'embed': embed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? revision,
      Value<String>? message,
      Value<String>? senderDid,
      Value<String?>? replyTo,
      Value<DateTime>? sentAt,
      Value<bool>? persisted,
      Value<bool>? read,
      Value<String>? embed,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      message: message ?? this.message,
      senderDid: senderDid ?? this.senderDid,
      replyTo: replyTo ?? this.replyTo,
      sentAt: sentAt ?? this.sentAt,
      persisted: persisted ?? this.persisted,
      read: read ?? this.read,
      embed: embed ?? this.embed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<String>(revision.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (senderDid.present) {
      map['sender_did'] = Variable<String>(senderDid.value);
    }
    if (replyTo.present) {
      map['reply_to'] = Variable<String>(replyTo.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (persisted.present) {
      map['persisted'] = Variable<bool>(persisted.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (embed.present) {
      map['embed'] = Variable<String>(embed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('message: $message, ')
          ..write('senderDid: $senderDid, ')
          ..write('replyTo: $replyTo, ')
          ..write('sentAt: $sentAt, ')
          ..write('persisted: $persisted, ')
          ..write('read: $read, ')
          ..write('embed: $embed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatRoomTable extends ChatRoom
    with TableInfo<$ChatRoomTable, ChatRoomData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<String> rev = GeneratedColumn<String>(
      'rev', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _membersMeta =
      const VerificationMeta('members');
  @override
  late final GeneratedColumn<String> members = GeneratedColumn<String>(
      'members', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
      'muted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("muted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
      'hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rev, members, lastMessage, muted, hidden, unreadCount, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_room';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRoomData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rev')) {
      context.handle(
          _revMeta, rev.isAcceptableOrUnknown(data['rev']!, _revMeta));
    } else if (isInserting) {
      context.missing(_revMeta);
    }
    if (data.containsKey('members')) {
      context.handle(_membersMeta,
          members.isAcceptableOrUnknown(data['members']!, _membersMeta));
    } else if (isInserting) {
      context.missing(_membersMeta);
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    } else if (isInserting) {
      context.missing(_lastMessageMeta);
    }
    if (data.containsKey('muted')) {
      context.handle(
          _mutedMeta, muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta));
    }
    if (data.containsKey('hidden')) {
      context.handle(_hiddenMeta,
          hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRoomData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rev: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rev'])!,
      members: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}members'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message'])!,
      muted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}muted'])!,
      hidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hidden'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $ChatRoomTable createAlias(String alias) {
    return $ChatRoomTable(attachedDatabase, alias);
  }
}

class ChatRoomData extends DataClass implements Insertable<ChatRoomData> {
  final String id;
  final String rev;
  final String members;
  final String lastMessage;
  final bool muted;
  final bool hidden;
  final int unreadCount;
  final DateTime lastUpdated;
  const ChatRoomData(
      {required this.id,
      required this.rev,
      required this.members,
      required this.lastMessage,
      required this.muted,
      required this.hidden,
      required this.unreadCount,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rev'] = Variable<String>(rev);
    map['members'] = Variable<String>(members);
    map['last_message'] = Variable<String>(lastMessage);
    map['muted'] = Variable<bool>(muted);
    map['hidden'] = Variable<bool>(hidden);
    map['unread_count'] = Variable<int>(unreadCount);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  ChatRoomCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomCompanion(
      id: Value(id),
      rev: Value(rev),
      members: Value(members),
      lastMessage: Value(lastMessage),
      muted: Value(muted),
      hidden: Value(hidden),
      unreadCount: Value(unreadCount),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory ChatRoomData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomData(
      id: serializer.fromJson<String>(json['id']),
      rev: serializer.fromJson<String>(json['rev']),
      members: serializer.fromJson<String>(json['members']),
      lastMessage: serializer.fromJson<String>(json['lastMessage']),
      muted: serializer.fromJson<bool>(json['muted']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rev': serializer.toJson<String>(rev),
      'members': serializer.toJson<String>(members),
      'lastMessage': serializer.toJson<String>(lastMessage),
      'muted': serializer.toJson<bool>(muted),
      'hidden': serializer.toJson<bool>(hidden),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  ChatRoomData copyWith(
          {String? id,
          String? rev,
          String? members,
          String? lastMessage,
          bool? muted,
          bool? hidden,
          int? unreadCount,
          DateTime? lastUpdated}) =>
      ChatRoomData(
        id: id ?? this.id,
        rev: rev ?? this.rev,
        members: members ?? this.members,
        lastMessage: lastMessage ?? this.lastMessage,
        muted: muted ?? this.muted,
        hidden: hidden ?? this.hidden,
        unreadCount: unreadCount ?? this.unreadCount,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  @override
  String toString() {
    return (StringBuffer('ChatRoomData(')
          ..write('id: $id, ')
          ..write('rev: $rev, ')
          ..write('members: $members, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('muted: $muted, ')
          ..write('hidden: $hidden, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rev, members, lastMessage, muted, hidden, unreadCount, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomData &&
          other.id == this.id &&
          other.rev == this.rev &&
          other.members == this.members &&
          other.lastMessage == this.lastMessage &&
          other.muted == this.muted &&
          other.hidden == this.hidden &&
          other.unreadCount == this.unreadCount &&
          other.lastUpdated == this.lastUpdated);
}

class ChatRoomCompanion extends UpdateCompanion<ChatRoomData> {
  final Value<String> id;
  final Value<String> rev;
  final Value<String> members;
  final Value<String> lastMessage;
  final Value<bool> muted;
  final Value<bool> hidden;
  final Value<int> unreadCount;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const ChatRoomCompanion({
    this.id = const Value.absent(),
    this.rev = const Value.absent(),
    this.members = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.muted = const Value.absent(),
    this.hidden = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatRoomCompanion.insert({
    required String id,
    required String rev,
    required String members,
    required String lastMessage,
    this.muted = const Value.absent(),
    this.hidden = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rev = Value(rev),
        members = Value(members),
        lastMessage = Value(lastMessage),
        lastUpdated = Value(lastUpdated);
  static Insertable<ChatRoomData> custom({
    Expression<String>? id,
    Expression<String>? rev,
    Expression<String>? members,
    Expression<String>? lastMessage,
    Expression<bool>? muted,
    Expression<bool>? hidden,
    Expression<int>? unreadCount,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rev != null) 'rev': rev,
      if (members != null) 'members': members,
      if (lastMessage != null) 'last_message': lastMessage,
      if (muted != null) 'muted': muted,
      if (hidden != null) 'hidden': hidden,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatRoomCompanion copyWith(
      {Value<String>? id,
      Value<String>? rev,
      Value<String>? members,
      Value<String>? lastMessage,
      Value<bool>? muted,
      Value<bool>? hidden,
      Value<int>? unreadCount,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return ChatRoomCompanion(
      id: id ?? this.id,
      rev: rev ?? this.rev,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      muted: muted ?? this.muted,
      hidden: hidden ?? this.hidden,
      unreadCount: unreadCount ?? this.unreadCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rev.present) {
      map['rev'] = Variable<String>(rev.value);
    }
    if (members.present) {
      map['members'] = Variable<String>(members.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomCompanion(')
          ..write('id: $id, ')
          ..write('rev: $rev, ')
          ..write('members: $members, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('muted: $muted, ')
          ..write('hidden: $hidden, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatRoomMessagesTable extends ChatRoomMessages
    with TableInfo<$ChatRoomMessagesTable, ChatRoomMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES messages(id) NOT NULL');
  static const VerificationMeta _chatRoomIdMeta =
      const VerificationMeta('chatRoomId');
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
      'chat_room_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES chat_room(id) NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [chatId, chatRoomId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_room_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatRoomMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
          _chatRoomIdMeta,
          chatRoomId.isAcceptableOrUnknown(
              data['chat_room_id']!, _chatRoomIdMeta));
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, chatRoomId};
  @override
  ChatRoomMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomMessage(
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_id'])!,
      chatRoomId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chat_room_id'])!,
    );
  }

  @override
  $ChatRoomMessagesTable createAlias(String alias) {
    return $ChatRoomMessagesTable(attachedDatabase, alias);
  }
}

class ChatRoomMessage extends DataClass implements Insertable<ChatRoomMessage> {
  final String chatId;
  final String chatRoomId;
  const ChatRoomMessage({required this.chatId, required this.chatRoomId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<String>(chatId);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    return map;
  }

  ChatRoomMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomMessagesCompanion(
      chatId: Value(chatId),
      chatRoomId: Value(chatRoomId),
    );
  }

  factory ChatRoomMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomMessage(
      chatId: serializer.fromJson<String>(json['chatId']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<String>(chatId),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
    };
  }

  ChatRoomMessage copyWith({String? chatId, String? chatRoomId}) =>
      ChatRoomMessage(
        chatId: chatId ?? this.chatId,
        chatRoomId: chatRoomId ?? this.chatRoomId,
      );
  @override
  String toString() {
    return (StringBuffer('ChatRoomMessage(')
          ..write('chatId: $chatId, ')
          ..write('chatRoomId: $chatRoomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, chatRoomId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomMessage &&
          other.chatId == this.chatId &&
          other.chatRoomId == this.chatRoomId);
}

class ChatRoomMessagesCompanion extends UpdateCompanion<ChatRoomMessage> {
  final Value<String> chatId;
  final Value<String> chatRoomId;
  final Value<int> rowid;
  const ChatRoomMessagesCompanion({
    this.chatId = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatRoomMessagesCompanion.insert({
    required String chatId,
    required String chatRoomId,
    this.rowid = const Value.absent(),
  })  : chatId = Value(chatId),
        chatRoomId = Value(chatRoomId);
  static Insertable<ChatRoomMessage> custom({
    Expression<String>? chatId,
    Expression<String>? chatRoomId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatRoomMessagesCompanion copyWith(
      {Value<String>? chatId, Value<String>? chatRoomId, Value<int>? rowid}) {
    return ChatRoomMessagesCompanion(
      chatId: chatId ?? this.chatId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomMessagesCompanion(')
          ..write('chatId: $chatId, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MessageDatabase extends GeneratedDatabase {
  _$MessageDatabase(QueryExecutor e) : super(e);
  _$MessageDatabaseManager get managers => _$MessageDatabaseManager(this);
  late final $SendersTable senders = $SendersTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ChatRoomTable chatRoom = $ChatRoomTable(this);
  late final $ChatRoomMessagesTable chatRoomMessages =
      $ChatRoomMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [senders, messages, chatRoom, chatRoomMessages];
}

typedef $$SendersTableInsertCompanionBuilder = SendersCompanion Function({
  required String did,
  required String displayName,
  Value<String?> avatarUrl,
  Value<int> rowid,
});
typedef $$SendersTableUpdateCompanionBuilder = SendersCompanion Function({
  Value<String> did,
  Value<String> displayName,
  Value<String?> avatarUrl,
  Value<int> rowid,
});

class $$SendersTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $SendersTable,
    Sender,
    $$SendersTableFilterComposer,
    $$SendersTableOrderingComposer,
    $$SendersTableProcessedTableManager,
    $$SendersTableInsertCompanionBuilder,
    $$SendersTableUpdateCompanionBuilder> {
  $$SendersTableTableManager(_$MessageDatabase db, $SendersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SendersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SendersTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$SendersTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> did = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SendersCompanion(
            did: did,
            displayName: displayName,
            avatarUrl: avatarUrl,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String did,
            required String displayName,
            Value<String?> avatarUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SendersCompanion.insert(
            did: did,
            displayName: displayName,
            avatarUrl: avatarUrl,
            rowid: rowid,
          ),
        ));
}

class $$SendersTableProcessedTableManager extends ProcessedTableManager<
    _$MessageDatabase,
    $SendersTable,
    Sender,
    $$SendersTableFilterComposer,
    $$SendersTableOrderingComposer,
    $$SendersTableProcessedTableManager,
    $$SendersTableInsertCompanionBuilder,
    $$SendersTableUpdateCompanionBuilder> {
  $$SendersTableProcessedTableManager(super.$state);
}

class $$SendersTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $SendersTable> {
  $$SendersTableFilterComposer(super.$state);
  ColumnFilters<String> get did => $state.composableBuilder(
      column: $state.table.did,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter messagesRefs(
      ComposableFilter Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.did,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.senderDid,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$SendersTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $SendersTable> {
  $$SendersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get did => $state.composableBuilder(
      column: $state.table.did,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatarUrl => $state.composableBuilder(
      column: $state.table.avatarUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MessagesTableInsertCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String revision,
  required String message,
  required String senderDid,
  Value<String?> replyTo,
  required DateTime sentAt,
  Value<bool> persisted,
  Value<bool> read,
  required String embed,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> revision,
  Value<String> message,
  Value<String> senderDid,
  Value<String?> replyTo,
  Value<DateTime> sentAt,
  Value<bool> persisted,
  Value<bool> read,
  Value<String> embed,
  Value<int> rowid,
});

class $$MessagesTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableProcessedTableManager,
    $$MessagesTableInsertCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder> {
  $$MessagesTableTableManager(_$MessageDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessagesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MessagesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> revision = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> senderDid = const Value.absent(),
            Value<String?> replyTo = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<bool> persisted = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<String> embed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            revision: revision,
            message: message,
            senderDid: senderDid,
            replyTo: replyTo,
            sentAt: sentAt,
            persisted: persisted,
            read: read,
            embed: embed,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String revision,
            required String message,
            required String senderDid,
            Value<String?> replyTo = const Value.absent(),
            required DateTime sentAt,
            Value<bool> persisted = const Value.absent(),
            Value<bool> read = const Value.absent(),
            required String embed,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            revision: revision,
            message: message,
            senderDid: senderDid,
            replyTo: replyTo,
            sentAt: sentAt,
            persisted: persisted,
            read: read,
            embed: embed,
            rowid: rowid,
          ),
        ));
}

class $$MessagesTableProcessedTableManager extends ProcessedTableManager<
    _$MessageDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableProcessedTableManager,
    $$MessagesTableInsertCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder> {
  $$MessagesTableProcessedTableManager(super.$state);
}

class $$MessagesTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get revision => $state.composableBuilder(
      column: $state.table.revision,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get replyTo => $state.composableBuilder(
      column: $state.table.replyTo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get sentAt => $state.composableBuilder(
      column: $state.table.sentAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get persisted => $state.composableBuilder(
      column: $state.table.persisted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get read => $state.composableBuilder(
      column: $state.table.read,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get embed => $state.composableBuilder(
      column: $state.table.embed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$SendersTableFilterComposer get senderDid {
    final $$SendersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.senderDid,
        referencedTable: $state.db.senders,
        getReferencedColumn: (t) => t.did,
        builder: (joinBuilder, parentComposers) => $$SendersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.senders, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter chatRoomMessagesRefs(
      ComposableFilter Function($$ChatRoomMessagesTableFilterComposer f) f) {
    final $$ChatRoomMessagesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.chatRoomMessages,
            getReferencedColumn: (t) => t.chatId,
            builder: (joinBuilder, parentComposers) =>
                $$ChatRoomMessagesTableFilterComposer(ComposerState($state.db,
                    $state.db.chatRoomMessages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get revision => $state.composableBuilder(
      column: $state.table.revision,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get replyTo => $state.composableBuilder(
      column: $state.table.replyTo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get sentAt => $state.composableBuilder(
      column: $state.table.sentAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get persisted => $state.composableBuilder(
      column: $state.table.persisted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get read => $state.composableBuilder(
      column: $state.table.read,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get embed => $state.composableBuilder(
      column: $state.table.embed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$SendersTableOrderingComposer get senderDid {
    final $$SendersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.senderDid,
        referencedTable: $state.db.senders,
        getReferencedColumn: (t) => t.did,
        builder: (joinBuilder, parentComposers) =>
            $$SendersTableOrderingComposer(ComposerState(
                $state.db, $state.db.senders, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ChatRoomTableInsertCompanionBuilder = ChatRoomCompanion Function({
  required String id,
  required String rev,
  required String members,
  required String lastMessage,
  Value<bool> muted,
  Value<bool> hidden,
  Value<int> unreadCount,
  required DateTime lastUpdated,
  Value<int> rowid,
});
typedef $$ChatRoomTableUpdateCompanionBuilder = ChatRoomCompanion Function({
  Value<String> id,
  Value<String> rev,
  Value<String> members,
  Value<String> lastMessage,
  Value<bool> muted,
  Value<bool> hidden,
  Value<int> unreadCount,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});

class $$ChatRoomTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $ChatRoomTable,
    ChatRoomData,
    $$ChatRoomTableFilterComposer,
    $$ChatRoomTableOrderingComposer,
    $$ChatRoomTableProcessedTableManager,
    $$ChatRoomTableInsertCompanionBuilder,
    $$ChatRoomTableUpdateCompanionBuilder> {
  $$ChatRoomTableTableManager(_$MessageDatabase db, $ChatRoomTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatRoomTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatRoomTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ChatRoomTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> id = const Value.absent(),
            Value<String> rev = const Value.absent(),
            Value<String> members = const Value.absent(),
            Value<String> lastMessage = const Value.absent(),
            Value<bool> muted = const Value.absent(),
            Value<bool> hidden = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomCompanion(
            id: id,
            rev: rev,
            members: members,
            lastMessage: lastMessage,
            muted: muted,
            hidden: hidden,
            unreadCount: unreadCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String rev,
            required String members,
            required String lastMessage,
            Value<bool> muted = const Value.absent(),
            Value<bool> hidden = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            required DateTime lastUpdated,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomCompanion.insert(
            id: id,
            rev: rev,
            members: members,
            lastMessage: lastMessage,
            muted: muted,
            hidden: hidden,
            unreadCount: unreadCount,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
        ));
}

class $$ChatRoomTableProcessedTableManager extends ProcessedTableManager<
    _$MessageDatabase,
    $ChatRoomTable,
    ChatRoomData,
    $$ChatRoomTableFilterComposer,
    $$ChatRoomTableOrderingComposer,
    $$ChatRoomTableProcessedTableManager,
    $$ChatRoomTableInsertCompanionBuilder,
    $$ChatRoomTableUpdateCompanionBuilder> {
  $$ChatRoomTableProcessedTableManager(super.$state);
}

class $$ChatRoomTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $ChatRoomTable> {
  $$ChatRoomTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rev => $state.composableBuilder(
      column: $state.table.rev,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get members => $state.composableBuilder(
      column: $state.table.members,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastMessage => $state.composableBuilder(
      column: $state.table.lastMessage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get muted => $state.composableBuilder(
      column: $state.table.muted,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get hidden => $state.composableBuilder(
      column: $state.table.hidden,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get unreadCount => $state.composableBuilder(
      column: $state.table.unreadCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter chatRoomMessagesRefs(
      ComposableFilter Function($$ChatRoomMessagesTableFilterComposer f) f) {
    final $$ChatRoomMessagesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.chatRoomMessages,
            getReferencedColumn: (t) => t.chatRoomId,
            builder: (joinBuilder, parentComposers) =>
                $$ChatRoomMessagesTableFilterComposer(ComposerState($state.db,
                    $state.db.chatRoomMessages, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ChatRoomTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $ChatRoomTable> {
  $$ChatRoomTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rev => $state.composableBuilder(
      column: $state.table.rev,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get members => $state.composableBuilder(
      column: $state.table.members,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastMessage => $state.composableBuilder(
      column: $state.table.lastMessage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get muted => $state.composableBuilder(
      column: $state.table.muted,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get hidden => $state.composableBuilder(
      column: $state.table.hidden,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get unreadCount => $state.composableBuilder(
      column: $state.table.unreadCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastUpdated => $state.composableBuilder(
      column: $state.table.lastUpdated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ChatRoomMessagesTableInsertCompanionBuilder
    = ChatRoomMessagesCompanion Function({
  required String chatId,
  required String chatRoomId,
  Value<int> rowid,
});
typedef $$ChatRoomMessagesTableUpdateCompanionBuilder
    = ChatRoomMessagesCompanion Function({
  Value<String> chatId,
  Value<String> chatRoomId,
  Value<int> rowid,
});

class $$ChatRoomMessagesTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $ChatRoomMessagesTable,
    ChatRoomMessage,
    $$ChatRoomMessagesTableFilterComposer,
    $$ChatRoomMessagesTableOrderingComposer,
    $$ChatRoomMessagesTableProcessedTableManager,
    $$ChatRoomMessagesTableInsertCompanionBuilder,
    $$ChatRoomMessagesTableUpdateCompanionBuilder> {
  $$ChatRoomMessagesTableTableManager(
      _$MessageDatabase db, $ChatRoomMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatRoomMessagesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatRoomMessagesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ChatRoomMessagesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> chatId = const Value.absent(),
            Value<String> chatRoomId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomMessagesCompanion(
            chatId: chatId,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String chatId,
            required String chatRoomId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatRoomMessagesCompanion.insert(
            chatId: chatId,
            chatRoomId: chatRoomId,
            rowid: rowid,
          ),
        ));
}

class $$ChatRoomMessagesTableProcessedTableManager
    extends ProcessedTableManager<
        _$MessageDatabase,
        $ChatRoomMessagesTable,
        ChatRoomMessage,
        $$ChatRoomMessagesTableFilterComposer,
        $$ChatRoomMessagesTableOrderingComposer,
        $$ChatRoomMessagesTableProcessedTableManager,
        $$ChatRoomMessagesTableInsertCompanionBuilder,
        $$ChatRoomMessagesTableUpdateCompanionBuilder> {
  $$ChatRoomMessagesTableProcessedTableManager(super.$state);
}

class $$ChatRoomMessagesTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $ChatRoomMessagesTable> {
  $$ChatRoomMessagesTableFilterComposer(super.$state);
  $$MessagesTableFilterComposer get chatId {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return composer;
  }

  $$ChatRoomTableFilterComposer get chatRoomId {
    final $$ChatRoomTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatRoomId,
        referencedTable: $state.db.chatRoom,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ChatRoomTableFilterComposer(ComposerState(
                $state.db, $state.db.chatRoom, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ChatRoomMessagesTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $ChatRoomMessagesTable> {
  $$ChatRoomMessagesTableOrderingComposer(super.$state);
  $$MessagesTableOrderingComposer get chatId {
    final $$MessagesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatId,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableOrderingComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return composer;
  }

  $$ChatRoomTableOrderingComposer get chatRoomId {
    final $$ChatRoomTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chatRoomId,
        referencedTable: $state.db.chatRoom,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ChatRoomTableOrderingComposer(ComposerState(
                $state.db, $state.db.chatRoom, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$MessageDatabaseManager {
  final _$MessageDatabase _db;
  _$MessageDatabaseManager(this._db);
  $$SendersTableTableManager get senders =>
      $$SendersTableTableManager(_db, _db.senders);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ChatRoomTableTableManager get chatRoom =>
      $$ChatRoomTableTableManager(_db, _db.chatRoom);
  $$ChatRoomMessagesTableTableManager get chatRoomMessages =>
      $$ChatRoomMessagesTableTableManager(_db, _db.chatRoomMessages);
}
