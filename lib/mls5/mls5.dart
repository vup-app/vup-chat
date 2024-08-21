import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:lib5/src/util/big_endian.dart';
import 'package:lib5/util.dart';
import 'package:ntp/ntp.dart';
import 'package:s5/s5.dart';
import 'package:s5/src/hive_key_value_db.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/mls5/state/main_window.dart';
import 'package:vup_chat/src/rust/api/simple.dart';
import 'package:vup_chat/src/rust/frb_generated.dart';
import 'package:hive/hive.dart';

import 'util/state.dart';
import 'model/message.dart';

// TODO There are too many saveKeyStore() calls in here, some of them are redundant and can be removed

class MLS5 {
  final mainWindowState = MainWindowState();

  late final Box dataBox;
  late final Box groupsBox;
  late final Box groupCursorBox;

  late final Box messageStoreBox;

  late final Box keystoreBox;
  // late final KeyValueDB groupStateDB;

  late final OpenMlsConfig config;

  S5 get s5 => msg.s5!;
  CryptoImplementation get crypto => s5.crypto;

  final rust = RustLib.instance.api;

  Future<void> init([String prefix = 'default']) async {
    dataBox = await Hive.openBox('vup-chat-data');
    groupsBox = await Hive.openBox('vup-chat-groups');

    final databaseEncryptionKey = Uint8List(32);

    messageStoreBox = await Hive.openBox(
      'vup-chat-messages',
      encryptionCipher: HiveAesCipher(
        databaseEncryptionKey,
      ),
    );

    // ! if it breaks
    // groupsBox.clear();

    groupCursorBox = await Hive.openBox('vup-chat-groups-cursor');

    keystoreBox = /*  HiveKeyValueDB( */ await Hive.openBox('$prefix-keystore');
    // groupStateDB = HiveKeyValueDB(await Hive.openBox('group_state'));

    config = await rust.crateApiSimpleOpenmlsInitConfig(
      keystoreDump:
          (keystoreBox.get('dump')?.cast<int>() ?? <int>[]) as List<int>,
    );
    print('Initialized Rust!');

    await setupIdentity();

    // TODO This is to ensure enough s5 peers are connected (can be removed in the future)
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      await recoverGroups();
      mainWindowState.update();
    });

    _setupTimeSync();
  }

  Duration timeOffset = Duration.zero;

  void _setupTimeSync() async {
    try {
      int offsetMillis = await NTP.getNtpOffset(localTime: DateTime.now());
      timeOffset = Duration(milliseconds: offsetMillis);
      print('timeOffset $timeOffset');
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  Future<HiveKeyValueDB> openDB(String key) async {
    return HiveKeyValueDB(await Hive.openBox('s5-node-$key'));
  }

  Future<void> saveKeyStore() async {
    print('saveKeyStore');
    keystoreBox.put(
      'dump',
      await rust.crateApiSimpleOpenmlsKeystoreDump(config: config),
    );
  }

  late final MlsCredential identity;

  Future<void> setupIdentity() async {
    const key = 'identity_default';
    if (dataBox.containsKey(key)) {
      final data = dataBox.get(key) as Map;
      identity = await openmlsRecoverCredentialWithKey(
        identity: utf8.encode(data['identity']),
        publicKey: base64UrlNoPaddingDecode(data['publicKey']),
        config: config,
      );
      print('$key recovered');
    } else {
      final username = 'User #${Random().nextInt(1000)}';
      identity = await openmlsGenerateCredentialWithKey(
        identity: utf8.encode(username),
        config: config,
      );
      final publicKey = await openmlsSignerGetPublicKey(
        signer: identity.signer,
      );

      dataBox.put(key, {
        'identity': username,
        'publicKey': base64UrlNoPaddingEncode(publicKey),
      });
      print('$key created');
    }
    await saveKeyStore();
  }

  final groups = <String, GroupState>{};

  GroupState group(String id) => groups[id]!;

  Future<String> createNewGroup() async {
    final group = await openmlsGroupCreate(
      signer: identity.signer,
      credentialWithKey: identity.credentialWithKey,
      config: config,
    );
    final groupId = base64UrlNoPaddingEncode(
        await openmlsGroupSave(group: group, config: config));
    await saveKeyStore();

    groups[groupId] = GroupState(
      groupId,
      group: group,
      channel: await deriveCommunicationChannelKeyPair(groupId),
      mls: this,
    );
    groups[groupId]!.init();

    groupsBox.put(
      groupId,
      {
        'id': groupId,
        'name': 'Group #${groupsBox.length + 1}',
      },
    );

    return groupId;
  }

  Future<KeyPairEd25519> deriveCommunicationChannelKeyPair(String groupId) {
    // TODO Better impl
    return crypto.newKeyPairEd25519(
      seed: crypto.hashBlake3Sync(
        base64UrlNoPaddingDecode(groupId),
        /*    5,
        crypto: node.crypto, */
      ),
    );
  }

  Future<void> recoverGroups() async {
    for (final id in groupsBox.keys) {
      final group = await openmlsGroupLoad(
        id: base64UrlNoPaddingDecode(id),
        config: config,
      );
      groups[id] = GroupState(
        id,
        group: group,
        channel: await deriveCommunicationChannelKeyPair(id),
        mls: this,
      );
      groups[id]!.init();
    }
    await saveKeyStore();
  }

  Future<Uint8List> createKeyPackage() async {
    final keyPackage = await openmlsGenerateKeyPackage(
      signer: identity.signer,
      credentialWithKey: identity.credentialWithKey,
      config: config,
    );
    await saveKeyStore();
    return keyPackage;
  }

  Future<String> acceptInviteAndJoinGroup(Uint8List welcomeIn) async {
    final group = await openmlsGroupJoin(
      welcomeIn: welcomeIn,
      config: config,
    );
    // TODO Prevent duplicate ID overwrite attacks!
    final groupId = base64UrlNoPaddingEncode(
      await openmlsGroupSave(group: group, config: config),
    );
    await saveKeyStore();

    groups[groupId] = GroupState(
      groupId,
      group: group,
      channel: await deriveCommunicationChannelKeyPair(groupId),
      mls: this,
    );
    groups[groupId]!.init();

    groupsBox.put(
      groupId,
      {
        'id': groupId,
        'name': 'Group #${groupsBox.length + 1}',
      },
    );
    groups[groupId]!.sendMessage('joined the group');
    return groupId;
  }
}

class GroupState {
  final String groupId;
  GroupState(
    this.groupId, {
    required this.group,
    required this.channel,
    required this.mls,
  });

  final MLS5 mls;

  final ignoreMessageIds = <int>{};
  final MlsGroup group;
  final KeyPairEd25519 channel;

  bool isInitialized = false;

  final messageListStateNotifier = StateNotifier();

  final membersStateNotifier = StateNotifier();
  List<GroupMember> members = [];
  // GroupMember? self;

  void init() {
    if (isInitialized) return;
    isInitialized = true;
    listenForIncomingMessages();
    initGroupMemberListSync();
  }

  void listenForIncomingMessages() async {
    // messagesTemp[groupId] = [];

    await for (final event in mls.s5.api.streamSubscribe(
      channel.publicKey,
      afterTimestamp: mls.groupCursorBox.get(groupId),
    )) {
      print('debug1 incoming $groupId ${event.ts}');
      try {
        if (ignoreMessageIds.contains(event.ts)) {
          print('debug1 ignore incoming message $groupId ${event.ts}');
          await mls.groupCursorBox.put(groupId, event.ts);
          return;
        }
        if ((mls.groupCursorBox.get(groupId) ?? -1) >= event.ts) {
          print('skipping message, unexpected ts');
          return;
        }
        final res = await openmlsGroupProcessIncomingMessage(
          group: group,
          mlsMessageIn: event.data,
          config: mls.config,
        );

        await mls.saveKeyStore();
        if (res.isApplicationMessage) {
          print('processed incoming message, epoch is ${res.epoch}');

          final msg = MLSApplicationMessage.fromProcessIncomingMessageResponse(
            res,
            event.ts,
          );
          _processNewMessage(msg);
        } else {
          refreshGroupMemberList();
        }
        await mls.groupCursorBox.put(groupId, event.ts);
      } catch (e, st) {
        print(e);
        print(st);
      }
    }
  }

  void _processNewMessage(MLSApplicationMessage msg) {
    messagesMemory.insert(0, msg);
    mls.messageStoreBox.put(makeKey(msg), msg.serialize());
    messageListStateNotifier.update();
  }

  bool canLoadMore = true;
  final messagesMemory = <MLSApplicationMessage>[];

  void loadMoreMessages() {
    final anchorLow = String.fromCharCodes(base64UrlNoPaddingDecode(groupId));
    final anchorHigh = messagesMemory.isEmpty
        ? String.fromCharCodes(base64UrlNoPaddingDecode(groupId) + [255])
        : makeKey(messagesMemory.last);
    final keys = mls.messageStoreBox.keys
        .where(
          (k) => k.compareTo(anchorLow) > 0 && k.compareTo(anchorHigh) < 0,
        )
        .toList();
    keys.sort((a, b) => b.compareTo(a));
    // print(keys);

    if (keys.length < 50) {
      canLoadMore = false;
    } else {
      keys.removeRange(50, keys.length);
    }
    for (final String k in keys) {
      messagesMemory.add(
        MLSApplicationMessage.deserialize(
          mls.messageStoreBox.get(k)!,
          decodeEndian(
            Uint8List.fromList(
              k.codeUnits.reversed.take(8).toList(),
            ),
          ),
        ),
      );
    }
    /*  if (keys.isEmpty) {
    } */

    messageListStateNotifier.update();
  }

/*   void _loadMoreMessages() {
  } */

  String makeKey(MLSApplicationMessage msg) {
    // final seq = encodeEndian(msg.ts, 8);
/*     
    return '$groupId/${msg.ts}'; */
    return String.fromCharCodes(
      Uint8List.fromList(
        base64UrlNoPaddingDecode(groupId) + encodeBigEndian(msg.ts, 8),
      ),
    );
  }

  void initGroupMemberListSync() {
    refreshGroupMemberList();
    // TODO Properly implement this
  }

  Future<void> refreshGroupMemberList() async {
    members = await openmlsGroupListMembers(group: group);

    // TODO This one is likely not needed
    await mls.saveKeyStore();
    /* try {
      final selfHash= Multihash(mls.identity)
      self = members.firstWhere((m) => Multihash(m.signatureKey)==);
    } catch (e, st) {
      // TODO Error handling
      print(e);
      print(st);
    } */
    membersStateNotifier.update();
  }

  Future<String> addMemberToGroup(
    Uint8List keyPackage,
  ) async {
    final res = await openmlsGroupAddMember(
      group: group,
      signer: mls.identity.signer,
      keyPackage: keyPackage,
      config: mls.config,
    );
    await mls.saveKeyStore();

    final ts = await sendMessageToStreamChannel(res.mlsMessageOut);
    await openmlsGroupSave(group: group, config: mls.config);

    refreshGroupMemberList();

    await mls.saveKeyStore();

/*     return 'mls5-group-invite:${base64UrlNoPaddingEncode(groupChannels[groupId]!.publicKey)}/$ts/${base64UrlNoPaddingEncode(res.welcomeOut)}'; */
    return base64UrlNoPaddingEncode(res.welcomeOut);
  }

  Future<void> sendMessage(String text) async {
    final msg = TextMessage(
      text: text,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    final message = Uint8List.fromList(
      msg.prefix + msg.serialize(),
    );

    final payload = await openmlsGroupCreateMessage(
      group: group,
      signer: mls.identity.signer,
      message: message,
      config: mls.config,
    );
    final ts = await sendMessageToStreamChannel(payload);
    await mls.saveKeyStore();

    _processNewMessage(
      MLSApplicationMessage(
        msg: msg,
        identity: Uint8List(0),
        sender: Uint8List(0),
        ts: ts,
      ),
    );
  }

  Future<int> sendMessageToStreamChannel(Uint8List message) async {
    final msg = await SignedStreamMessage.create(
      kp: channel,
      data: message,
      ts: DateTime.now()
          .add(mls.timeOffset)
          .millisecondsSinceEpoch, // TODO Maybe use microseconds or seq numbers  to further avoid collisions on the s5 streams transport layer
      crypto: mls.crypto,
    );

    ignoreMessageIds.add(msg.ts);
    await mls.s5.api.streamPublish(msg);
    return msg.ts;
  }

  void rename(String newName) {
    final Map map = mls.groupsBox.get(groupId);
    map['name'] = newName;
    mls.groupsBox.put(
      groupId,
      map,
    );
    mls.mainWindowState.update();
  }

/*   final ignoreMessageIds = <String, Set<int>>{};
  final groups = <String, MlsGroup>{};
  final groupChannels = <String, KeyPairEd25519>{};
  final newMessageStreams = <String, StreamController<Message>>{};
  final messagesTemp = <String, List<Message>>{}; */
}
