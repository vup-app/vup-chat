import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/log_out.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Future<void> _logOut() async {
    session = await tryLogOut();
    if (mounted && session == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: const Text("heso"));
  }
}
