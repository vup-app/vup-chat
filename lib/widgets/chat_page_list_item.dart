import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';

Widget buildChatPageListItem(
    ConvoView convo, Animation<double> animation, BuildContext context) {
  final String title = convo.members.map((m) => m.displayName).last ?? "null";
  final CircleAvatar avatar = convo.members.last.avatar != null
      ? CircleAvatar(backgroundImage: NetworkImage(convo.members.last.avatar!))
      : const CircleAvatar(child: Icon(Icons.person));
  return SizeTransition(
    sizeFactor: animation,
    child: ListTile(
      title: Text(title),
      subtitle: Text(convo.lastMessage!.toJson()['text']),
      leading: avatar,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatIndividualPage(
                      id: convo.id,
                      otherName: title,
                      avatar: avatar,
                    )));
      },
    ),
  );
}
