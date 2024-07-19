import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

class ChatRoomListItem extends StatefulWidget {
  final ChatRoom chat;
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
  Uint8List? avatarBytesCache;

  @override
  void initState() {
    avatarBytesCache = widget.chat.avatar;
    super.initState();
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
          jsonDecode(widget.chat.lastMessage)["text"] ?? "",
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

// TODO: Fix this pointing to the wrong chat
class ChatRoomSearchMessageItem extends StatefulWidget {
  final Message message;

  const ChatRoomSearchMessageItem({super.key, required this.message});

  @override
  ChatRoomSearchMessageItemState createState() =>
      ChatRoomSearchMessageItemState();
}

class ChatRoomSearchMessageItemState extends State<ChatRoomSearchMessageItem> {
  Sender? sender;
  ChatRoom? chatRoom;
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
        }));
    msg!.getChatIDFromMessageID(widget.message.id).then((val) => setState(() {
          chatID = val;
          if (val != null && val.isNotEmpty) {
            msg!.getChatRoomFromChatID(val).then((val2) => setState(() {
                  chatRoom = val2;
                  avatarBytesCache = val2?.avatar;
                }));
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        chatRoom?.roomName ?? "",
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: true,
      ),
      subtitle: Text(
        "${(sender?.did == did) ? "You" : (sender?.displayName ?? "")}: ${widget.message.message}",
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

class ChatRoomSearchGroupItem extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomSearchGroupItem({super.key, required this.chatRoom});

  @override
  ChatRoomSearchGroupItemState createState() => ChatRoomSearchGroupItemState();
}

class ChatRoomSearchGroupItemState extends State<ChatRoomSearchGroupItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.chatRoom.roomName,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: true,
      ),
      leading: CircleAvatar(
        backgroundImage: (widget.chatRoom.avatar != null)
            ? Image.memory(widget.chatRoom.avatar!).image
            : null,
      ),
      onTap: () {
        vupSplitViewKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatIndividualPage(
                      id: widget.chatRoom.id,
                    )),
            (Route<dynamic> route) => route.isFirst);
      },
    );
  }
}

Widget buildChatRoomSearchItemActor() {
  return Container();
}
