import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vup_chat/functions/general.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

Widget buildChatRoomListItem(
    ChatRoomData chat,
    Animation<double> animation,
    BuildContext context,
    HomeRoutingService? homeRoutingService,
    Set<String>? selectedItems,
    Function(String) onItemPressed) {
  // Parse members and last message
  final List<dynamic> membersJson = jsonDecode(chat.members);
  final Map<String, dynamic> lastMessageJson = json.decode(chat.lastMessage);

  final String title =
      handleFromMembersJSON(membersJson, chat.members.isNotEmpty);
  final CircleAvatar avatar = avatarFromMembersJSON(membersJson);
  final String lastMessageText = lastMessageJson['text'] ?? "";

  return SizeTransition(
    sizeFactor: animation,
    child: ListTile(
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        softWrap: true,
      ),
      subtitle: Text(
        lastMessageText,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        softWrap: true,
      ),
      leading: avatar,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          (chat.muted)
              ? const Icon(Icons.notifications_off_outlined)
              : Container(),
          SmartDateTimeWidget(dateTime: chat.lastUpdated)
        ],
      ),
      onTap: () {
        if (selectedItems != null && selectedItems.isNotEmpty) {
          onItemPressed(chat.id);
        } else if (homeRoutingService != null) {
          homeRoutingService.onChatSelected(chat.id, null);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatIndividualPage(
                        id: chat.id,
                      )));
        }
      },
    ),
  );
}

Widget buildChatRoomSearchItemMessage(
    Message message, BuildContext ctx, HomeRoutingService? homeRoutingService) {
  return FutureBuilder<List<dynamic>>(
    future: Future.wait([
      msg!.getSenderFromDID(message.senderDid),
      msg!.getChatIDFromMessageID(message.id)
    ]),
    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
        // return const Text('Loading....');
        default:
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.data != null &&
                snapshot.data![0] != null &&
                snapshot.data![1] != null) {
              Sender? sender = snapshot.data![0] as Sender?;
              String chatID = snapshot.data![1] as String;

              CircleAvatar cavatar = (sender != null)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(sender.avatarUrl!))
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    );
              return (sender != null)
                  ? ListTile(
                      title: Text(sender.displayName),
                      subtitle: Text(message.message),
                      leading: cavatar,
                      onTap: () {
                        if (homeRoutingService != null) {
                          homeRoutingService.onChatSelected(chatID, message.id);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatIndividualPage(
                                        id: chatID,
                                        messageIdToScrollTo: message.id,
                                      )));
                        }
                      },
                    )
                  : const Text("failed to fetch sender");
            } else {
              return const Text("Failed fetching profile or chat data");
            }
          }
      }
    },
  );
}

Widget buildChatRoomSearchItemActor() {
  return Container();
}
