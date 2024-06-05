import 'package:bluesky/bluesky.dart';
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

  final bluesky = Bluesky.fromSession(
    session.data,
  );

  return bluesky;
}
