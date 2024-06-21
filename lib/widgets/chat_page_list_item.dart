import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';

Widget buildChatListPageListItem(ChatRoomData chat, Animation<double> animation,
    BuildContext context, HomeRoutingService? homeRoutingService) {
  // Parse members and last message
  final List<dynamic> membersJson = jsonDecode(chat.members);
  final Map<String, dynamic> lastMessageJson = json.decode(chat.lastMessage);

  final String title =
      chat.members.isNotEmpty ? membersJson.last["displayName"] : "null";
  final CircleAvatar avatar = membersJson.isNotEmpty &&
          membersJson.last['avatar'] != null
      ? CircleAvatar(backgroundImage: NetworkImage(membersJson.last['avatar']))
      : const CircleAvatar(child: Icon(Icons.person));
  final String lastMessageText = lastMessageJson['text'] ?? "";

  return SizeTransition(
    sizeFactor: animation,
    child: ListTile(
      title: Text(title),
      subtitle: Text(lastMessageText),
      leading: avatar,
      onTap: () {
        if (homeRoutingService != null) {
          homeRoutingService.onChatSelected(chat.id, title, avatar);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatIndividualPage(
                        id: chat.id,
                        otherName: title,
                        avatar: avatar,
                      )));
        }
      },
    ),
  );
}
