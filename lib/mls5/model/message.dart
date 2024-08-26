import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:vup_chat/definitions/s5_embed.dart';
import 'package:vup_chat/mls5/constants.dart';
import 'package:vup_chat/src/rust/api/simple.dart';

class MLSApplicationMessage {
  final Uint8List sender;
  final Uint8List identity;
  final Message msg;
  final int ts;

  MLSApplicationMessage({
    required this.msg,
    required this.identity,
    required this.sender,
    required this.ts,
  });

  Uint8List serialize() {
    if (sender.length > 230) throw 'Sender too long';
    if (identity.length > 100) throw 'identity too long';
    return Uint8List.fromList(
      [sender.length] +
          sender +
          [identity.length] +
          identity +
          msg.prefix +
          msg.serialize(),
    );
  }

  static MLSApplicationMessage fromProcessIncomingMessageResponse(
    ProcessIncomingMessageResponse res,
    int ts,
  ) {
    if (res.applicationMessage[0] != mlsApplicationMessagePrefixVupChat) {
      throw 'Unsupported application message prefix ${res.applicationMessage[0]}';
    }
    final Message msg;
    if (res.applicationMessage[1] == vupChatTextMessageJSON) {
      msg = TextMessage.deserialize(res.applicationMessage.sublist(2));
    } else {
      throw 'Unsupported vup chat message type prefix ${res.applicationMessage[1]}';
    }
    return MLSApplicationMessage(
      msg: msg,
      identity: res.identity,
      sender: res.sender,
      ts: ts,
    );
  }

  static MLSApplicationMessage deserialize(
    Uint8List data,
    int ts,
  ) {
    final senderLength = data[0];
    final identityLength = data[senderLength + 1];
    return fromProcessIncomingMessageResponse(
      ProcessIncomingMessageResponse(
        isApplicationMessage: true,
        applicationMessage: data.sublist(senderLength + identityLength + 2),
        identity:
            data.sublist(senderLength + 2, senderLength + identityLength + 2),
        sender: data.sublist(1, 1 + senderLength),
        epoch: BigInt.from(0),
      ),
      ts,
    );
  }
}

abstract class Message {
  List<int> get prefix;
  Uint8List serialize();
}

class TextMessage extends Message {
  @override
  final prefix = [
    mlsApplicationMessagePrefixVupChat,
    vupChatTextMessageJSON,
  ];

  final String text;
  final int ts; // when this post was created, in milliseconds?
  final String did; // sender ATProto DID
  final S5Embed? embed;
  final String id;

  // Create an instance of Uuid
  static const Uuid uuid = Uuid();

  TextMessage({
    required this.text,
    required this.ts,
    required this.did,
    this.embed,
    String? id,
  }) : id = id ?? uuid.v4(); // If `id` is null, assign `Uuid().v4()` to `id`.

  @override
  Uint8List serialize() => utf8.encode(
        jsonEncode(
          {
            'text': text,
            'ts': ts,
            'did': did,
            'embed': (embed != null) ? jsonEncode(embed!.toJson()) : null,
            'id': id,
          },
        ),
      );

  static Message deserialize(
    Uint8List data,
  ) {
    final body = jsonDecode(utf8.decode(data));

    return TextMessage(
      text: body['text'],
      ts: body['ts'],
      did: body['did'],
      embed: (body['embed'] != null)
          ? S5Embed.fromJson(jsonDecode(body['embed']))
          : null,
      id: body['id'],
    );
  }
}
