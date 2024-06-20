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

class $ContentTable extends Content with TableInfo<$ContentTable, ContentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cidMeta = const VerificationMeta('cid');
  @override
  late final GeneratedColumn<String> cid = GeneratedColumn<String>(
      'cid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content';
  @override
  VerificationContext validateIntegrity(Insertable<ContentData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cid')) {
      context.handle(
          _cidMeta, cid.isAcceptableOrUnknown(data['cid']!, _cidMeta));
    } else if (isInserting) {
      context.missing(_cidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cid};
  @override
  ContentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentData(
      cid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cid'])!,
    );
  }

  @override
  $ContentTable createAlias(String alias) {
    return $ContentTable(attachedDatabase, alias);
  }
}

class ContentData extends DataClass implements Insertable<ContentData> {
  final String cid;
  const ContentData({required this.cid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cid'] = Variable<String>(cid);
    return map;
  }

  ContentCompanion toCompanion(bool nullToAbsent) {
    return ContentCompanion(
      cid: Value(cid),
    );
  }

  factory ContentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentData(
      cid: serializer.fromJson<String>(json['cid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cid': serializer.toJson<String>(cid),
    };
  }

  ContentData copyWith({String? cid}) => ContentData(
        cid: cid ?? this.cid,
      );
  @override
  String toString() {
    return (StringBuffer('ContentData(')
          ..write('cid: $cid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => cid.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ContentData && other.cid == this.cid);
}

class ContentCompanion extends UpdateCompanion<ContentData> {
  final Value<String> cid;
  final Value<int> rowid;
  const ContentCompanion({
    this.cid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentCompanion.insert({
    required String cid,
    this.rowid = const Value.absent(),
  }) : cid = Value(cid);
  static Insertable<ContentData> custom({
    Expression<String>? cid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cid != null) 'cid': cid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentCompanion copyWith({Value<String>? cid, Value<int>? rowid}) {
    return ContentCompanion(
      cid: cid ?? this.cid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cid.present) {
      map['cid'] = Variable<String>(cid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentCompanion(')
          ..write('cid: $cid, ')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, revision, message, senderDid, replyTo, sentAt];
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
  const Message(
      {required this.id,
      required this.revision,
      required this.message,
      required this.senderDid,
      this.replyTo,
      required this.sentAt});
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
    };
  }

  Message copyWith(
          {String? id,
          String? revision,
          String? message,
          String? senderDid,
          Value<String?> replyTo = const Value.absent(),
          DateTime? sentAt}) =>
      Message(
        id: id ?? this.id,
        revision: revision ?? this.revision,
        message: message ?? this.message,
        senderDid: senderDid ?? this.senderDid,
        replyTo: replyTo.present ? replyTo.value : this.replyTo,
        sentAt: sentAt ?? this.sentAt,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('message: $message, ')
          ..write('senderDid: $senderDid, ')
          ..write('replyTo: $replyTo, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, revision, message, senderDid, replyTo, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.message == this.message &&
          other.senderDid == this.senderDid &&
          other.replyTo == this.replyTo &&
          other.sentAt == this.sentAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> revision;
  final Value<String> message;
  final Value<String> senderDid;
  final Value<String?> replyTo;
  final Value<DateTime> sentAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.message = const Value.absent(),
    this.senderDid = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String revision,
    required String message,
    required String senderDid,
    this.replyTo = const Value.absent(),
    required DateTime sentAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        revision = Value(revision),
        message = Value(message),
        senderDid = Value(senderDid),
        sentAt = Value(sentAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? revision,
    Expression<String>? message,
    Expression<String>? senderDid,
    Expression<String>? replyTo,
    Expression<DateTime>? sentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (message != null) 'message': message,
      if (senderDid != null) 'sender_did': senderDid,
      if (replyTo != null) 'reply_to': replyTo,
      if (sentAt != null) 'sent_at': sentAt,
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
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      message: message ?? this.message,
      senderDid: senderDid ?? this.senderDid,
      replyTo: replyTo ?? this.replyTo,
      sentAt: sentAt ?? this.sentAt,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageListTable extends MessageList
    with TableInfo<$MessageListTable, MessageListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageListTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'message_list';
  @override
  VerificationContext validateIntegrity(Insertable<MessageListData> instance,
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
  MessageListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageListData(
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
  $MessageListTable createAlias(String alias) {
    return $MessageListTable(attachedDatabase, alias);
  }
}

class MessageListData extends DataClass implements Insertable<MessageListData> {
  final String id;
  final String rev;
  final String members;
  final String lastMessage;
  final bool muted;
  final bool hidden;
  final int unreadCount;
  final DateTime lastUpdated;
  const MessageListData(
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

  MessageListCompanion toCompanion(bool nullToAbsent) {
    return MessageListCompanion(
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

  factory MessageListData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageListData(
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

  MessageListData copyWith(
          {String? id,
          String? rev,
          String? members,
          String? lastMessage,
          bool? muted,
          bool? hidden,
          int? unreadCount,
          DateTime? lastUpdated}) =>
      MessageListData(
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
    return (StringBuffer('MessageListData(')
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
      (other is MessageListData &&
          other.id == this.id &&
          other.rev == this.rev &&
          other.members == this.members &&
          other.lastMessage == this.lastMessage &&
          other.muted == this.muted &&
          other.hidden == this.hidden &&
          other.unreadCount == this.unreadCount &&
          other.lastUpdated == this.lastUpdated);
}

class MessageListCompanion extends UpdateCompanion<MessageListData> {
  final Value<String> id;
  final Value<String> rev;
  final Value<String> members;
  final Value<String> lastMessage;
  final Value<bool> muted;
  final Value<bool> hidden;
  final Value<int> unreadCount;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const MessageListCompanion({
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
  MessageListCompanion.insert({
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
  static Insertable<MessageListData> custom({
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

  MessageListCompanion copyWith(
      {Value<String>? id,
      Value<String>? rev,
      Value<String>? members,
      Value<String>? lastMessage,
      Value<bool>? muted,
      Value<bool>? hidden,
      Value<int>? unreadCount,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return MessageListCompanion(
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
    return (StringBuffer('MessageListCompanion(')
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

class $MessageListMessagesTable extends MessageListMessages
    with TableInfo<$MessageListMessagesTable, MessageListMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageListMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES messages(id) NOT NULL');
  static const VerificationMeta _messageListIdMeta =
      const VerificationMeta('messageListId');
  @override
  late final GeneratedColumn<String> messageListId = GeneratedColumn<String>(
      'message_list_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES message_list(id) NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [messageId, messageListId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_list_messages';
  @override
  VerificationContext validateIntegrity(Insertable<MessageListMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('message_list_id')) {
      context.handle(
          _messageListIdMeta,
          messageListId.isAcceptableOrUnknown(
              data['message_list_id']!, _messageListIdMeta));
    } else if (isInserting) {
      context.missing(_messageListIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, messageListId};
  @override
  MessageListMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageListMessage(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      messageListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}message_list_id'])!,
    );
  }

  @override
  $MessageListMessagesTable createAlias(String alias) {
    return $MessageListMessagesTable(attachedDatabase, alias);
  }
}

class MessageListMessage extends DataClass
    implements Insertable<MessageListMessage> {
  final String messageId;
  final String messageListId;
  const MessageListMessage(
      {required this.messageId, required this.messageListId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['message_list_id'] = Variable<String>(messageListId);
    return map;
  }

  MessageListMessagesCompanion toCompanion(bool nullToAbsent) {
    return MessageListMessagesCompanion(
      messageId: Value(messageId),
      messageListId: Value(messageListId),
    );
  }

  factory MessageListMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageListMessage(
      messageId: serializer.fromJson<String>(json['messageId']),
      messageListId: serializer.fromJson<String>(json['messageListId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'messageListId': serializer.toJson<String>(messageListId),
    };
  }

  MessageListMessage copyWith({String? messageId, String? messageListId}) =>
      MessageListMessage(
        messageId: messageId ?? this.messageId,
        messageListId: messageListId ?? this.messageListId,
      );
  @override
  String toString() {
    return (StringBuffer('MessageListMessage(')
          ..write('messageId: $messageId, ')
          ..write('messageListId: $messageListId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, messageListId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageListMessage &&
          other.messageId == this.messageId &&
          other.messageListId == this.messageListId);
}

class MessageListMessagesCompanion extends UpdateCompanion<MessageListMessage> {
  final Value<String> messageId;
  final Value<String> messageListId;
  final Value<int> rowid;
  const MessageListMessagesCompanion({
    this.messageId = const Value.absent(),
    this.messageListId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageListMessagesCompanion.insert({
    required String messageId,
    required String messageListId,
    this.rowid = const Value.absent(),
  })  : messageId = Value(messageId),
        messageListId = Value(messageListId);
  static Insertable<MessageListMessage> custom({
    Expression<String>? messageId,
    Expression<String>? messageListId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (messageListId != null) 'message_list_id': messageListId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageListMessagesCompanion copyWith(
      {Value<String>? messageId,
      Value<String>? messageListId,
      Value<int>? rowid}) {
    return MessageListMessagesCompanion(
      messageId: messageId ?? this.messageId,
      messageListId: messageListId ?? this.messageListId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (messageListId.present) {
      map['message_list_id'] = Variable<String>(messageListId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageListMessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('messageListId: $messageListId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MessageDatabase extends GeneratedDatabase {
  _$MessageDatabase(QueryExecutor e) : super(e);
  _$MessageDatabaseManager get managers => _$MessageDatabaseManager(this);
  late final $SendersTable senders = $SendersTable(this);
  late final $ContentTable content = $ContentTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MessageListTable messageList = $MessageListTable(this);
  late final $MessageListMessagesTable messageListMessages =
      $MessageListMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [senders, content, messages, messageList, messageListMessages];
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

typedef $$ContentTableInsertCompanionBuilder = ContentCompanion Function({
  required String cid,
  Value<int> rowid,
});
typedef $$ContentTableUpdateCompanionBuilder = ContentCompanion Function({
  Value<String> cid,
  Value<int> rowid,
});

class $$ContentTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $ContentTable,
    ContentData,
    $$ContentTableFilterComposer,
    $$ContentTableOrderingComposer,
    $$ContentTableProcessedTableManager,
    $$ContentTableInsertCompanionBuilder,
    $$ContentTableUpdateCompanionBuilder> {
  $$ContentTableTableManager(_$MessageDatabase db, $ContentTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ContentTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ContentTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) => $$ContentTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> cid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentCompanion(
            cid: cid,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String cid,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentCompanion.insert(
            cid: cid,
            rowid: rowid,
          ),
        ));
}

class $$ContentTableProcessedTableManager extends ProcessedTableManager<
    _$MessageDatabase,
    $ContentTable,
    ContentData,
    $$ContentTableFilterComposer,
    $$ContentTableOrderingComposer,
    $$ContentTableProcessedTableManager,
    $$ContentTableInsertCompanionBuilder,
    $$ContentTableUpdateCompanionBuilder> {
  $$ContentTableProcessedTableManager(super.$state);
}

class $$ContentTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $ContentTable> {
  $$ContentTableFilterComposer(super.$state);
  ColumnFilters<String> get cid => $state.composableBuilder(
      column: $state.table.cid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ContentTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $ContentTable> {
  $$ContentTableOrderingComposer(super.$state);
  ColumnOrderings<String> get cid => $state.composableBuilder(
      column: $state.table.cid,
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
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> revision,
  Value<String> message,
  Value<String> senderDid,
  Value<String?> replyTo,
  Value<DateTime> sentAt,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            revision: revision,
            message: message,
            senderDid: senderDid,
            replyTo: replyTo,
            sentAt: sentAt,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String id,
            required String revision,
            required String message,
            required String senderDid,
            Value<String?> replyTo = const Value.absent(),
            required DateTime sentAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            revision: revision,
            message: message,
            senderDid: senderDid,
            replyTo: replyTo,
            sentAt: sentAt,
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

  ComposableFilter messageListMessagesRefs(
      ComposableFilter Function($$MessageListMessagesTableFilterComposer f) f) {
    final $$MessageListMessagesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.messageListMessages,
            getReferencedColumn: (t) => t.messageId,
            builder: (joinBuilder, parentComposers) =>
                $$MessageListMessagesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.messageListMessages,
                    joinBuilder,
                    parentComposers)));
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

typedef $$MessageListTableInsertCompanionBuilder = MessageListCompanion
    Function({
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
typedef $$MessageListTableUpdateCompanionBuilder = MessageListCompanion
    Function({
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

class $$MessageListTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $MessageListTable,
    MessageListData,
    $$MessageListTableFilterComposer,
    $$MessageListTableOrderingComposer,
    $$MessageListTableProcessedTableManager,
    $$MessageListTableInsertCompanionBuilder,
    $$MessageListTableUpdateCompanionBuilder> {
  $$MessageListTableTableManager(_$MessageDatabase db, $MessageListTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessageListTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessageListTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MessageListTableProcessedTableManager(p),
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
              MessageListCompanion(
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
              MessageListCompanion.insert(
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

class $$MessageListTableProcessedTableManager extends ProcessedTableManager<
    _$MessageDatabase,
    $MessageListTable,
    MessageListData,
    $$MessageListTableFilterComposer,
    $$MessageListTableOrderingComposer,
    $$MessageListTableProcessedTableManager,
    $$MessageListTableInsertCompanionBuilder,
    $$MessageListTableUpdateCompanionBuilder> {
  $$MessageListTableProcessedTableManager(super.$state);
}

class $$MessageListTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $MessageListTable> {
  $$MessageListTableFilterComposer(super.$state);
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

  ComposableFilter messageListMessagesRefs(
      ComposableFilter Function($$MessageListMessagesTableFilterComposer f) f) {
    final $$MessageListMessagesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.messageListMessages,
            getReferencedColumn: (t) => t.messageListId,
            builder: (joinBuilder, parentComposers) =>
                $$MessageListMessagesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.messageListMessages,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$MessageListTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $MessageListTable> {
  $$MessageListTableOrderingComposer(super.$state);
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

typedef $$MessageListMessagesTableInsertCompanionBuilder
    = MessageListMessagesCompanion Function({
  required String messageId,
  required String messageListId,
  Value<int> rowid,
});
typedef $$MessageListMessagesTableUpdateCompanionBuilder
    = MessageListMessagesCompanion Function({
  Value<String> messageId,
  Value<String> messageListId,
  Value<int> rowid,
});

class $$MessageListMessagesTableTableManager extends RootTableManager<
    _$MessageDatabase,
    $MessageListMessagesTable,
    MessageListMessage,
    $$MessageListMessagesTableFilterComposer,
    $$MessageListMessagesTableOrderingComposer,
    $$MessageListMessagesTableProcessedTableManager,
    $$MessageListMessagesTableInsertCompanionBuilder,
    $$MessageListMessagesTableUpdateCompanionBuilder> {
  $$MessageListMessagesTableTableManager(
      _$MessageDatabase db, $MessageListMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$MessageListMessagesTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$MessageListMessagesTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$MessageListMessagesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> messageId = const Value.absent(),
            Value<String> messageListId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageListMessagesCompanion(
            messageId: messageId,
            messageListId: messageListId,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String messageId,
            required String messageListId,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessageListMessagesCompanion.insert(
            messageId: messageId,
            messageListId: messageListId,
            rowid: rowid,
          ),
        ));
}

class $$MessageListMessagesTableProcessedTableManager
    extends ProcessedTableManager<
        _$MessageDatabase,
        $MessageListMessagesTable,
        MessageListMessage,
        $$MessageListMessagesTableFilterComposer,
        $$MessageListMessagesTableOrderingComposer,
        $$MessageListMessagesTableProcessedTableManager,
        $$MessageListMessagesTableInsertCompanionBuilder,
        $$MessageListMessagesTableUpdateCompanionBuilder> {
  $$MessageListMessagesTableProcessedTableManager(super.$state);
}

class $$MessageListMessagesTableFilterComposer
    extends FilterComposer<_$MessageDatabase, $MessageListMessagesTable> {
  $$MessageListMessagesTableFilterComposer(super.$state);
  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.messageId,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableFilterComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return composer;
  }

  $$MessageListTableFilterComposer get messageListId {
    final $$MessageListTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.messageListId,
        referencedTable: $state.db.messageList,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessageListTableFilterComposer(ComposerState($state.db,
                $state.db.messageList, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MessageListMessagesTableOrderingComposer
    extends OrderingComposer<_$MessageDatabase, $MessageListMessagesTable> {
  $$MessageListMessagesTableOrderingComposer(super.$state);
  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.messageId,
        referencedTable: $state.db.messages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessagesTableOrderingComposer(ComposerState(
                $state.db, $state.db.messages, joinBuilder, parentComposers)));
    return composer;
  }

  $$MessageListTableOrderingComposer get messageListId {
    final $$MessageListTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.messageListId,
        referencedTable: $state.db.messageList,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MessageListTableOrderingComposer(ComposerState($state.db,
                $state.db.messageList, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$MessageDatabaseManager {
  final _$MessageDatabase _db;
  _$MessageDatabaseManager(this._db);
  $$SendersTableTableManager get senders =>
      $$SendersTableTableManager(_db, _db.senders);
  $$ContentTableTableManager get content =>
      $$ContentTableTableManager(_db, _db.content);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MessageListTableTableManager get messageList =>
      $$MessageListTableTableManager(_db, _db.messageList);
  $$MessageListMessagesTableTableManager get messageListMessages =>
      $$MessageListMessagesTableTableManager(_db, _db.messageListMessages);
}
