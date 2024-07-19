import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/text_input_page.dart';

class ChatInfoPage extends StatefulWidget {
  final ChatRoom chatRoomData;

  const ChatInfoPage({
    required this.chatRoomData,
    super.key,
  });

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  late ChatRoom _chatRoomData;
  List<Sender>? _senders;

  @override
  void initState() {
    _chatRoomData = widget.chatRoomData;
    msg!.getSendersFromDIDList(widget.chatRoomData.members).then((val) {
      setState(() {
        _senders = val;
        logger.d(_senders);
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
            // Displays the circle avatar of room
            CircleAvatar(
              radius: 80.h,
              backgroundImage: (widget.chatRoomData.avatar == null)
                  ? null
                  : Image.memory(widget.chatRoomData.avatar!).image,
            ),

            // Displays the editable room name
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
            // Displays room count
            Text("Group with ${_senders?.length} members:"),
            // Displays room members below that
            SizedBox(
              width: 200.h,
              child: (_senders == null)
                  ? null
                  : ListView.builder(
                      itemCount: _senders!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Sender? sndr = _senders?[index];
                        if (sndr != null) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (sndr.avatar != null)
                                  ? Image.memory(sndr.avatar!).image
                                  : null,
                            ),
                            title: Text(
                              (sndr.did == did) ? "You" : sndr.displayName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: (sndr.description != null)
                                ? Text(
                                    sndr.description!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                                : null,
                          );
                        }
                        return null;
                      }),
            )
            // TODO: Display media & Links like whatsapp
          ],
        ));
  }
}
