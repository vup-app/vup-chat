import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

Widget buildMessageItem(
    Message message, Animation<double> animation, BuildContext context) {
  final isMe = message.senderDid == did;
  return SizeTransition(
    sizeFactor: animation,
    child: Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message.message));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text copied to clipboard')),
          );
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                message.message,
                style: TextStyle(
                  color: isMe ? Theme.of(context).cardColor : Colors.black,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Icon(
                message.persisted ? Icons.check : Icons.hourglass_bottom,
                color: Colors.grey,
                size: 16,
              ),
            ),
            Positioned(
                bottom: 8,
                right: 25,
                child: SmartDateTimeWidget(
                  dateTime: message.sentAt,
                  fontSize: 6,
                  color: Theme.of(context).secondaryHeaderColor,
                  mode: 1,
                )),
          ],
        ),
      ),
    ),
  );
}
