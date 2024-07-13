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

class ChatRoomSearchItem extends StatefulWidget {
  final Message message;

  const ChatRoomSearchItem({super.key, required this.message});

  @override
  ChatRoomSearchItemState createState() => ChatRoomSearchItemState();
}

class ChatRoomSearchItemState extends State<ChatRoomSearchItem> {
  Sender? sender;
  String? chatID;
  Uint8List? avatarBytesCache;

  @override
  void initState() {
    _getIDAndSender();
    super.initState();
  }

  void _getIDAndSender() {
    msg!.getSenderFromDID(widget.message.senderDid).then((val) => setState(() {
          sender = val;
          if (sender != null) {
            avatarBytesCache = sender!.avatar;
          }
        }));
    msg!.getChatIDFromMessageID(widget.message.id).then((val) => setState(() {
          chatID = val;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        sender?.displayName ?? "",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: true,
      ),
      subtitle: Text(
        widget.message.message,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: true,
      ),
      leading: CircleAvatar(
        backgroundImage: (avatarBytesCache != null)
            ? Image.memory(avatarBytesCache!).image
            : null,
      ),
      onTap: () {
        if (chatID != null) {
          vupSplitViewKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => ChatIndividualPage(
                        id: chatID!,
                        messageIdToScrollTo: widget.message.id,
                      )),
              (Route<dynamic> route) => route.isFirst);
        }
      },
    );
  }
}

Widget buildChatRoomSearchItemActor() {
  return Container();
}
