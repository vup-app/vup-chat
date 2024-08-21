import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/screens/text_input_page.dart';
import 'package:vup_chat/widgets/smart_width.dart';

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
  int _callNotificationSliderState = 0;
  int _textNotificationSliderState = 0;
  final List<String> _notificationOptions = ["disable", "silent", "normal"];

  @override
  void initState() {
    _chatRoomData = widget.chatRoomData;
    _getNotificationLevels();
    msg.getSendersFromDIDList(widget.chatRoomData.members).then((val) {
      setState(() {
        _senders = val;
      });
    });
    super.initState();
  }

  Future<void> _getNotificationLevels() async {
    final List<String> prevNotificationLevels =
        widget.chatRoomData.notificationLevel.split("-");
    setState(() {
      try {
        _callNotificationSliderState =
            _notificationOptions.indexOf(prevNotificationLevels[0]);
        _textNotificationSliderState =
            _notificationOptions.indexOf(prevNotificationLevels[1]);
      } catch (e) {
        logger.e("Failed to parse notification levels");
      }
    });
  }

  Future<void> _persistNotificationState() async {
    await msg.db.setNotificationLevel(
        widget.chatRoomData.id,
        _notificationOptions[_callNotificationSliderState],
        _notificationOptions[_textNotificationSliderState]);
  }

  // This is for debug only
  void _removeMLSID() async {
    _chatRoomData = _chatRoomData.copyWith(mlsChatID: const Value(null));
    await msg.db.updateChatRoom(_chatRoomData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(child: LayoutBuilder(
          builder: (context, constraints) {
            return SmartWidth(
                child: ListView(
              children: [
                // Displays the circle avatar of room
                CircleAvatar(
                  radius: 80.h,
                  child: ClipOval(
                      child: (widget.chatRoomData.avatar == null)
                          ? null
                          : Image.memory(
                              widget.chatRoomData.avatar!,
                            )),
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
                              if ((value as String).isNotEmpty) {
                                msg.setRoomName(widget.chatRoomData.id, value);
                                msg
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
                Center(
                  child: Text("Group with ${_senders?.length} members:"),
                ),

                // Displays room members below that
                Center(
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
                ),
                // Shows the notification toggle
                const Center(
                  child: Text("Notifications:"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate the width for each indicator based on the total width
                          double totalWidth = constraints.maxWidth;
                          double indicatorWidth = totalWidth / 3;

                          return AnimatedToggleSwitch.size(
                            current: _callNotificationSliderState,
                            iconAnimationType: AnimationType.onHover,
                            onChanged: (value) {
                              setState(() {
                                _callNotificationSliderState = value;
                              });
                              _persistNotificationState();
                            },
                            values: const [0, 1, 2],
                            customIconBuilder: (context, local, global) {
                              return Text(_notificationOptions[local.value]);
                            },
                            indicatorSize: Size(
                                indicatorWidth, 48), // Set the height as needed
                            style: ToggleStyle(
                              indicatorColor: Theme.of(context).primaryColor,
                              borderColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                const BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.message),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate the width for each indicator based on the total width
                          double totalWidth = constraints.maxWidth;
                          double indicatorWidth = totalWidth / 3;

                          return AnimatedToggleSwitch.size(
                            current: _textNotificationSliderState,
                            iconAnimationType: AnimationType.onHover,
                            onChanged: (value) {
                              setState(() {
                                _textNotificationSliderState = value;
                              });
                              _persistNotificationState();
                            },
                            values: const [0, 1, 2],
                            customIconBuilder: (context, local, global) {
                              return Text(_notificationOptions[local.value]);
                            },
                            indicatorSize: Size.fromWidth(indicatorWidth),
                            style: ToggleStyle(
                              indicatorColor: Theme.of(context).primaryColor,
                              borderColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                const BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),

                // Display a button to go to starred messages
                ElevatedButton(
                  onPressed: () {
                    vupSplitViewKey.currentState?.push(MaterialPageRoute(
                        builder: (context) => ChatIndividualPage(
                            id: widget.chatRoomData.id, starredOnly: true)));
                  },
                  child: const ListTile(
                    title: Text("Starred Messages"),
                    trailing: Icon(Icons.arrow_forward),
                  ),
                ),

                // TODO: Display media & Links like whatsapp

                // DEBUG:
                (kDebugMode)
                    ? ElevatedButton(
                        onPressed: _removeMLSID,
                        child: const Text("Clear MLS ID"))
                    : Container(),
              ],
            ));
          },
        )));
  }
}
