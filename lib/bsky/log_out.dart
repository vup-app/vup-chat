import 'package:bluesky/bluesky.dart';
import 'package:vup_chat/main.dart';

Future<Bluesky?> tryLogOut() async {
  await secureStorage.write(key: 'user', value: null);
  await secureStorage.write(key: 'password', value: null);
  msg.bskySession = null;
  msg.bskyChatSession = null;
  preferences.setBool("logged-in", false);
  return null;
}
