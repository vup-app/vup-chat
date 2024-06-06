import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/screens/home_page.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();
Bluesky? session;
String? did;

void main() async {
  // grab login credentials and try to log in
  WidgetsFlutterBinding.ensureInitialized();
  session = await tryLogIn(null, null);

  runApp(const VupChat());
}

class VupChat extends StatelessWidget {
  const VupChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
