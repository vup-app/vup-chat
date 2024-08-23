import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/functions/getAvatar.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String text = "";
    try {
      text = jsonDecode(widget.chat.lastMessage)["text"] ?? "";
    } catch (_) {}
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
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
        leading: getCircleAvatar(widget.chat.avatar, widget.chat.avatarUrl),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (widget.chat.pinned)
                ? const Icon(Icons.push_pin_outlined)
                : Container(),
            (widget.chat.notificationLevel.split("-")[1] == "disable")
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
                    builder: (context) => ChatIndividualPage(
                          id: widget.chat.id,
                          starredOnly: false,
                        )),
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
    msg.getSenderFromDID(widget.message.senderDid).then((val) {
      if (mounted) {
        setState(() {
          sender = val;
        });
      }
    });
    msg.getChatIDFromMessageID(widget.message.id).then((val) => setState(() {
          chatID = val;
          if (val != null && val.isNotEmpty) {
            msg.getChatRoomFromChatID(val).then((val2) {
              if (mounted) {
                setState(() {
                  chatRoom = val2;
                  avatarBytesCache = val2?.avatar;
                });
              }
            });
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
      leading: getCircleAvatar(avatarBytesCache, chatRoom?.avatarUrl),
      onTap: () {
        if (chatID != null) {
          vupSplitViewKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => ChatIndividualPage(
                        id: chatID!,
                        messageIdToScrollTo: widget.message.id,
                        starredOnly: false,
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
      leading:
          getCircleAvatar(widget.chatRoom.avatar, widget.chatRoom.avatarUrl),
      onTap: () {
        vupSplitViewKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ChatIndividualPage(
                      id: widget.chatRoom.id,
                      starredOnly: false,
                    )),
            (Route<dynamic> route) => route.isFirst);
      },
    );
  }
}

Widget buildChatRoomSearchItemActor() {
  return Container();
}
