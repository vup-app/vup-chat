import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/chat_actions.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    getChatTimeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: const Text("heso"));
  }
}
