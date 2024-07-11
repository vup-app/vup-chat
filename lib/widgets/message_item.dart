import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/smart_date_time.dart';

// TODO: Change message UI to vengamo https://pub.dev/packages/vengamo_chat_ui
Widget buildMessageItem(
    Message message, Animation<double> animation, BuildContext context) {
  final isMe = message.senderDid == did;
  // do some logic on the embed to define widget
  late Widget bubbleContents;
  if (message.embed.isNotEmpty) {
    final Map<String, dynamic> s5EmbedJSON = jsonDecode(message.embed);
    bubbleContents = const Text("erm");
    logger.d(s5EmbedJSON);
  } else {
    bubbleContents = SelectableText(
      message.message,
      style: TextStyle(
        color: isMe ? Theme.of(context).cardColor : Colors.black,
      ),
      selectionControls: MaterialTextSelectionControls(),
    );
  }
  return SizeTransition(
    sizeFactor: animation,
    child: Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color:
                  isMe ? Theme.of(context).primaryColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Theme(
              data: ThemeData(
                  textSelectionTheme: const TextSelectionThemeData(
                selectionColor: Colors.green,
              )),
              child: bubbleContents,
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
  );
}
