import 'package:flutter/material.dart';
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
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: ThemeData(
                      textSelectionTheme: TextSelectionThemeData(
                    selectionColor: Theme.of(context).primaryColor,
                  )),
                  // This swaps between the selectable text and normal text when selection mode is
                  // on to make selection easier
                  child: (widget.selectedMessages.isNotEmpty)
                      ? Text(
                          widget.message.message,
                          style: TextStyle(
                            color: isMe
                                ? Theme.of(context).cardColor
                                : Colors.black,
                          ),
                        )
                      : SelectableText(
                          widget.message.message,
                          style: TextStyle(
                            color: isMe
                                ? Theme.of(context).cardColor
                                : Colors.black,
                          ),
                          selectionControls: MaterialTextSelectionControls(),
                        ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Icon(
                  widget.message.persisted
                      ? Icons.check
                      : Icons.hourglass_bottom,
                  color: Colors.grey,
                  size: 16,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 25,
                child: SmartDateTimeWidget(
                  dateTime: widget.message.sentAt,
                  fontSize: 6,
                  color: isMe ? Theme.of(context).cardColor : Colors.black,
                  mode: 1,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 48,
                child: (widget.message.starred)
                    ? const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 12,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
