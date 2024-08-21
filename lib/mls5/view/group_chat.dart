import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lib5/util.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/mls5/mls5.dart';
import 'package:vup_chat/mls5/model/message.dart';

class GroupChatView extends StatefulWidget {
  final String id;
  GroupChatView(this.id) : super(key: ValueKey('group-chat-$id'));

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView> {
  final textCtrl = TextEditingController();
  final textCtrlFocusNode = FocusNode();

  GroupState get group => mls5.group(widget.id);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Expanded(
              child: StreamBuilder<void>(
                stream: group.messageListStateNotifier.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: group.messagesMemory.length +
                        (group.canLoadMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == group.messagesMemory.length) {
                        group.loadMoreMessages();
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final msg = group.messagesMemory[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(msg.ts)
                                  .toIso8601String()
                                  .substring(11, 19),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              msg.identity.isEmpty
                                  ? 'You'
                                  : utf8.decode(msg.identity),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child:
                                  SelectableText((msg.msg as TextMessage).text),
                            ),
                            /* SelectableText(msg.ts.toString()), */
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: textCtrlFocusNode,
                controller: textCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your message',
                ),
                onSubmitted: (text) async {
                  await group.sendMessage(text);
                  textCtrl.clear();
                  textCtrlFocusNode.requestFocus();
                },
              ),
            ),
          ],
        )),
        SizedBox(
          width: 100.w,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final res = await showTextInputDialog(
                          context: context,
                          textFields: [
                            const DialogTextField(hintText: 'mls5-key-package:')
                          ],
                        );
                        if (res == null) return;
                        final String kp = res.first;
                        if (!kp.startsWith('mls5-key-package:')) throw 'TODO1';
                        final bytes = base64UrlNoPaddingDecode(
                          kp.substring(17),
                        );
                        print(bytes);

                        final welcomeMessage =
                            await group.addMemberToGroup(bytes);

                        print(welcomeMessage);

                        Clipboard.setData(
                          ClipboardData(
                            text: welcomeMessage,
                          ),
                        );

                        /* final kp = await mls.createKeyPackage();

                        */
                      },
                      child: const Text(
                        'Invite User',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<void>(
                  stream: group.membersStateNotifier.stream,
                  builder: (context, snapshot) {
                    return ListView(
                      children: [
                        for (final member in group.members)
                          ListTile(
                            title: Text(utf8.decode(member.identity)),
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
