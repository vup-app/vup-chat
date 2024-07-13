import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

class ChatRoomListItem extends StatefulWidget {
  final ChatRoomData chat;
  final Animation<double> animation;
  final Set<String>? selectedItems;
  final Function(String) onItemPressed;

  const ChatRoomListItem(
      {super.key,
      required this.chat,
      required this.animation,
      required this.selectedItems,
      required this.onItemPressed});

  @override
  ChatRoomListItemState createState() => ChatRoomListItemState();
}

class ChatRoomListItemState extends State<ChatRoomListItem> {
  String? lastMessageText;
  Uint8List? avatarBytesCache;

  @override
  void initState() {
    _getLastMessage();
    avatarBytesCache = widget.chat.avatar;
    super.initState();
  }

  _getLastMessage() async {
    Map<String, dynamic> lastMessageJson = json.decode(widget.chat.lastMessage);
    setState(() {
      lastMessageText = lastMessageJson['text'] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: ListTile(
        title: Text(
          widget.chat.roomName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
        subtitle: Text(
          lastMessageText ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
        leading: CircleAvatar(
          backgroundImage: (avatarBytesCache == null)
              ? null
              : Image.memory(avatarBytesCache!).image,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (widget.chat.muted)
                ? const Icon(Icons.notifications_off_outlined)
                : Container(),
            SmartDateTimeWidget(dateTime: widget.chat.lastUpdated)
          ],
        ),
        onTap: () {
          if (widget.selectedItems != null &&
              widget.selectedItems!.isNotEmpty) {
            widget.onItemPressed(widget.chat.id);
          } else {
            vupSplitViewKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        ChatIndividualPage(id: widget.chat.id)),
                (Route<dynamic> route) => route.isFirst);
          }
        },
      ),
    );
  }
}

Widget buildChatRoomSearchItemMessage(Message message, BuildContext ctx) {
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

              CircleAvatar cavatar = (sender != null && sender.avatar != null)
                  ? CircleAvatar(
                      backgroundImage: Image.memory(sender.avatar!).image)
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    );
              return (sender != null)
                  ? ListTile(
                      title: Text(sender.displayName),
                      subtitle: Text(message.message),
                      leading: cavatar,
                      onTap: () {
                        vupSplitViewKey.currentState?.pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => ChatIndividualPage(
                                      id: chatID,
                                      messageIdToScrollTo: message.id,
                                    )),
                            (Route<dynamic> route) => route.isFirst);
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
