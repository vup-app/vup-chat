import 'package:bluesky/atproto.dart';
import 'package:bluesky/core.dart';
import 'package:vup_chat/main.dart';

Future<Session?> tryLogIn(String? user, String? password) async {
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

  did = session.data.did;
  preferences.setBool("logged-in", true);
  return session.data;
}
