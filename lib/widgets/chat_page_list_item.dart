import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';

Widget buildChatListPageListItem(ConvoView convo, Animation<double> animation,
    BuildContext context, HomeRoutingService? homeRoutingService) {
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
        if (homeRoutingService != null) {
          homeRoutingService.onChatSelected(convo);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatIndividualPage(
                        id: convo.id,
                        otherName: title,
                        avatar: avatar,
                      )));
        }
      },
    ),
  );
}
