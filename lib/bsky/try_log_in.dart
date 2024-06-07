import 'package:bluesky/bluesky.dart';
import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:vup_chat/main.dart';
import 'package:did_plc/did_plc.dart' as plc;

Future<Bluesky?> tryLogIn(String? user, String? password) async {
  if (user == null || user.isEmpty || password == null || password.isEmpty) {
    user = await storage.read(key: 'user');
    password = await storage.read(key: 'password');
    if (user == null || user.isEmpty || password == null || password.isEmpty) {
      return null;
    }
  }
  final session = await createSession(
    identifier: user,
    password: password,
  );

  Bluesky blueskySession = Bluesky.fromSession(
    session.data,
  );
  did = session.data.did;

  Map<String, String> chatHeader = {
    "Atproto-Proxy": "did:web:api.bsky.chat#bsky_chat",
  };

  final plcClient = plc.PLC();
  final didDoc = await plcClient.findDocument(
    did: did!,
  );
  final serviceEndpoint =
      Uri.parse(didDoc.data.service.first.serviceEndpoint).host;

  BlueskyChat blueskyChatSession = BlueskyChat.fromSession(session.data,
      headers: chatHeader, service: serviceEndpoint);

  chatSession = blueskyChatSession;
  return blueskySession;
}
