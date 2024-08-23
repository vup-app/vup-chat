import 'dart:convert';

import 'package:bluesky/atproto.dart';
import 'package:bluesky/core.dart';
import 'package:drift/drift.dart';
import 'package:lib5/identity.dart';
import 'package:lib5/util.dart';
import 'package:vup_chat/definitions/key_entries.dart';
import 'package:vup_chat/definitions/logger.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/mls5/mls5.dart';

Future<void> enableMLS() async {
  // Not strictly necesary, but good to have in case other code changes later
  preferences.setBool("disable-mls", false);
  // Now the following:
  // - create pubkey
  // - create MLS keypair
  // - put those in json & stringify them
  // Set app.vup.chat.keys/default to this keypair
  final KeyEntry? ke = await getLocalKeyEntry();
  if (ke != null) {
    try {
      final XRPCResponse<StrongRef> createdRecord =
          await msg.bskySession!.atproto.repo.createRecord(
              collection: NSID.create(
                'chat.vup.app',
                'mlsKeys',
              ),
              record: {'keys': ke.toString()},
              rkey: "default",
              validate: false);
      logger.d(createdRecord);
    } catch (e) {
      // If it fails due to already having been set, try putting instead
      if (e.toString().contains("500")) {
        final XRPCResponse<StrongRef> createdRecord =
            await msg.bskySession!.atproto.repo.putRecord(
                uri: AtUri.parse("at://$did/app.vup.chat.mlsKeys/default"),
                record: {'keys': ke.toString()},
                validate: false);
        logger.d(createdRecord);
      }
    }
  }
}

void disableMLS() {
  // For now just set the shared preferences to disable it
  preferences.setBool("disable-mls", true);
}

// Creates the local key entry from user seed
// TODO: red, check my work here
Future<KeyEntry?> getLocalKeyEntry() async {
  final String? seed = await secureStorage.read(key: "seed");
  if (seed != null && msg.s5 != null && msg.bskySession != null) {
    final Uint8List hashedSeed = msg.s5!.api.crypto
        .hashBlake3Sync(validatePhrase(seed, crypto: msg.s5!.api.crypto));
    final Uint8List publicKey =
        (await msg.s5!.api.crypto.newKeyPairEd25519(seed: hashedSeed))
            .publicKey;
    final Uint8List keyPackage = await mls5.createKeyPackage();
    final KeyEntry ke = KeyEntry(kp: keyPackage, pk: publicKey);
    return ke;
  }
  return null;
}

// if the user is able to sucessfully recover from backups, this should never be called
// but in case the user swaps to a new node without restoring from backups, the MLS record
// should update
// This function purposely doesn't handle errors because I want to handle them up the stack
Future<void> updateOwnMLSRecord() async {
  if (did != null) {
    var record = (await msg.bskySession!.atproto.repo.getRecord(
            uri: AtUri.parse("at://$did/app.vup.chat.mlsKeys/default")))
        .data;
    KeyEntry keRemote = KeyEntry.fromString(record.value["keys"]);
    final KeyEntry? keLocal = await getLocalKeyEntry();
    logger.d(keLocal);
    if (keLocal != null) {
      // The pk should remain the same, so only need to compare the keypairs
      if (keRemote.kp != keLocal.kp) {
        final XRPCResponse<StrongRef> _ = await msg.bskySession!.atproto.repo
            .putRecord(
                uri: AtUri.make(did!, "app.vup.chat.mlsKeys", "default"),
                record: {'keys': keLocal.toString()},
                validate: false);
      }
    }
    record = (await msg.bskySession!.atproto.repo.getRecord(
            uri: AtUri.parse("at://$did/app.vup.chat.mlsKeys/default")))
        .data;
    keRemote = KeyEntry.fromString(record.value["keys"]);
  }
}

// This function does a couple things:
// 0. Checks if you're already in a chat room, if so it checks to see if there
//    are any users in it already.
// 1. It searches chat history to check if you've been invited already, if not
//    it sends out an invite to the other user using their pub keys. This will fail
//    if they haven't yet published their keys yet.
// 2. Return if the room is ready to send MLS chats or not.
Future<bool> ensureMLSEnabled(ChatRoom chatRoom) async {
  // If mlsChatID is null, and the OTHER USER has posted MLS keys,
  // create a room and write it to the db
  await getLocalKeyEntry();
  if (msg.bskySession != null && did != null) {
    String otherDID = ((await msg.getSendersFromDIDList(chatRoom.members))
        .firstWhere((t) => t.did != did)).did;
    if (chatRoom.mlsChatID == null) {
      try {
        // We don't actually currently care about the record itself, just that it exists
        // should probably build out code to lint it's contents at some point.
        final record = (await msg.bskySession!.atproto.repo.getRecord(
                uri:
                    AtUri.parse("at://$otherDID/app.vup.chat.mlsKeys/default")))
            .data;
        logger.d(record);
        logger.i("MLS record found for ${chatRoom.id}");
        final String mlsGroupID = await mls5.createNewGroup();
        // Now that we have a group, make sure to add it to the DB
        chatRoom = chatRoom.copyWith(mlsChatID: Value(mlsGroupID));
        // Don't write to DB for now so I can keep creating new ones to test
        await msg.db.updateChatRoom(chatRoom);
      } catch (e) {
        logger.e(e);
        // A 400 resp means that the entry was not found
        if (e.toString().contains("400")) {
          // Since the other user has not posted keys, we can safely disable these chats
          // This is the only real case where it makes sense to disable encrypted chats, as that
          // user has explicitly not posted MLS keys yet.
          logger.i("MLS record not found for ${chatRoom.id}");
          return false;
        }
      }
    }
    final GroupState mlsGroup = mls5.group(chatRoom.mlsChatID!);
    final List<Message> messagesPreCull = (await msg.searchMessages(
        "Vup Chat Encrypted Chat Invite", chatRoom.id));
    // Do this to make sure users typing in Vup Chat Encrypted Chat Invite in the middle of
    // messages won't collide
    final List<Message> messages = messagesPreCull.where((message) {
      return message.message.startsWith("Vup Chat Encrypted Chat Invite");
    }).toList();
    // We're assuming that there is ONLY ONE invite sent per channel it is possible that
    // both clients send an invite within a couple seconds of each other and shit breaks.
    // But for now I think this is a reasonable assumption to make.
    if (messages.isNotEmpty) {
      if (messages.first.senderDid != did) {
        // If the other party has sent an invite, join it.
        // TODO: red encrypt invite here
        // Have to concat the invite link back together
        // Map each Message object to  its message content and convert to a list of strings
        List<String> messageContents =
            messages.map((message) => message.message).toList();
        String invite = messageContents
                .where((m) => m.contains("(1)"))
                .first
                .substring(35) +
            messageContents.where((m) => m.contains("(2)")).first.substring(35);
        // logLongMessage(invite);
        try {
          final String mlsGroupID = await mls5
              .acceptInviteAndJoinGroup(base64UrlNoPaddingDecode(invite));
          chatRoom = chatRoom.copyWith(mlsChatID: Value(mlsGroupID));
          await msg.db.updateChatRoom(chatRoom);
          return true;
        } catch (e) {
          logger.e(e);
          return false;
        }
      }
    } else {
      // If there are no invites, create one and send it.
      try {
        // TODO: red encrypt invite here
        final record = (await msg.bskySession!.atproto.repo.getRecord(
                uri:
                    AtUri.parse("at://$otherDID/app.vup.chat.mlsKeys/default")))
            .data;
        KeyEntry ke = KeyEntry.fromString(record.value["keys"]);
        logger.d(ke);
        String invite = await mlsGroup.addMemberToGroup(ke.kp);
        // logLongMessage(invite);
        // bsky limits messages to 1000 chars long, but this invite is about 1100
        // we need to split it into two, and then reconsitute it later
        List<String> invites = [
          "Vup Chat Encrypted Chat Invite(1): ${invite.substring(0, (invite.length / 2).round())}",
          "Vup Chat Encrypted Chat Invite(2): ${invite.substring((invite.length / 2).round(), invite.length)}"
        ];
        Sender sender = await msg.getSenderFromDID(did!);
        // obv don't send this over encrypted because it has to go over ATProto
        for (String invite in invites) {
          msg.sendMessage(invite, chatRoom.id, sender, true);
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        logger.e(e);
      }
    }
  }
  // This is a crude way to do things, but there is no good way to easily actuall tell how many
  // people have joined a chat room, if you send an invite that is effectively them being in the chat room
  // the only better way I can think of is to check if the other user has sent an encrypted chat already that says
  // "joined" but that... isn't exactly a great way to do things. So I'm gonna allow you to send chats to a user that
  // hasn't officially joined the room yet. In theory, the S5 node should hold the messages until you fetch them
  // anyway, so this is *probably* fine
  if (chatRoom.mlsChatID != null) {
    return true;
  } else {
    return false;
  }
}
