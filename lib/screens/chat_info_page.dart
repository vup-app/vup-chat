import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/text_input_page.dart';

class ChatInfoPage extends StatefulWidget {
  final ChatRoomData chatRoomData;

  const ChatInfoPage({
    required this.chatRoomData,
    super.key,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  late ChatRoomData _chatRoomData;
  List<Sender>? _senders;

  @override
  void initState() {
    _chatRoomData = widget.chatRoomData;
    msg!.getSendersFromDIDList(widget.chatRoomData.members).then((val) {
      setState(() {
        _senders = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _chatRoomData.roomName,
                  style: const TextStyle(fontSize: 30),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                        PageRouteBuilder(
                          opaque: false, // set to false
                          pageBuilder: (_, __, ___) => (const TextInputPage(
                            title: "Change Room Name",
                          )),
                        ),
                      )
                          .then(
                        (value) {
                          if (msg != null && (value as String).isNotEmpty) {
                            msg!.setRoomName(widget.chatRoomData.id, value);
                            msg!
                                .getChatRoomFromChatID(_chatRoomData.id)
                                .then((val) {
                              if (val != null) {
                                setState(() {
                                  _chatRoomData = val;
                                });
                              }
                            });
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.edit))
              ],
            ),
            const Text("Members"),
          ],
        ));
  }
}
