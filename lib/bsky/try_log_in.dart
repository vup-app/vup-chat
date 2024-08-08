import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:bluesky/core.dart';
import 'package:vup_chat/main.dart';

Future<Bluesky?> tryLogIn(String? user, String? password) async {
  if (user == null || user.isEmpty || password == null || password.isEmpty) {
    user = await secureStorage.read(key: 'user');
    password = await secureStorage.read(key: 'password');
    if (user == null || user.isEmpty || password == null || password.isEmpty) {
      return null;
    }
  }
  XRPCResponse<Session> session;
  try {
    session = await createSession(
      identifier: user,
      password: password,
    );
  } catch (_) {
    return null;
  }

  Bluesky blueskySession = Bluesky.fromSession(
    session.data,
  );

  BlueskyChat blueskyChatSession = BlueskyChat.fromSession(session.data);

  did = session.data.did;
  chatSession = blueskyChatSession;
  preferences.setBool("logged-in", true);
  return blueskySession;
}
