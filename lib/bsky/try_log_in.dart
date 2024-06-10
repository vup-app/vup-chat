import 'package:bluesky/bluesky.dart';
import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:vup_chat/main.dart';

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

  BlueskyChat blueskyChatSession = BlueskyChat.fromSession(session.data);

  did = session.data.did;
  chatSession = blueskyChatSession;
  return blueskySession;
}
