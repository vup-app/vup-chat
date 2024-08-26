import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/constants.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final Animation<double> animation;
  final Set<Message> selectedMessages;
  final Function(Message) msgSelector;

  const MessageItem({
    super.key,
    required this.message,
    required this.animation,
    required this.selectedMessages,
    required this.msgSelector,
  });

  @override
  MessageItemState createState() => MessageItemState();
}

class MessageItemState extends State<MessageItem> {
  Widget bubbleContents = Container();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool widerThanBreakPoint = false;
    if (MediaQuery.sizeOf(context).width > 729) {
      widerThanBreakPoint = true;
    } else {
      widerThanBreakPoint = false;
    }
    bool isMe = (widget.message.senderDid == did);
    return SizeTransition(
      sizeFactor: widget.animation,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
            onLongPress: () => widget.msgSelector(widget.message),
            onTap: () {
              if (widget.selectedMessages.isNotEmpty) {
                widget.msgSelector(widget.message);
              }
            },
            child: Stack(
              children: [
                // This highlights the message if selected
                if (widget.selectedMessages.contains(widget.message))
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? (widget.message.encrypted == true)
                            ? Theme.of(context).primaryColor
                            : bskyColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                      minWidth: 90,
                      maxWidth: (widerThanBreakPoint) ? 220.w : 270.w),
                  child: Text(
                    widget.message.message,
                    style: TextStyle(
                      color: isMe ? Theme.of(context).cardColor : Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.message.starred)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SmartDateTimeWidget(
                          dateTime: widget.message.sentAt,
                          fontSize: 6,
                          color:
                              isMe ? Theme.of(context).cardColor : Colors.black,
                          mode: 1,
                        ),
                      ),
                      if (widget.message.encrypted)
                        Icon(
                          Icons.lock_outline,
                          color:
                              isMe ? Theme.of(context).cardColor : Colors.black,
                          size: 12,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          widget.message.persisted
                              ? Icons.check
                              : Icons.hourglass_bottom,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
