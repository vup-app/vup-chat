import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vup_chat/functions/general.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/app_bar_back.dart';
import 'package:vup_chat/widgets/message_item.dart';

class ChatIndividualPage extends StatefulWidget {
  final String id;
  final String? messageIdToScrollTo; // Optional parameter

  const ChatIndividualPage({
    super.key,
    required this.id,
    this.messageIdToScrollTo,
  });

  @override
  State<ChatIndividualPage> createState() => _ChatIndividualPageState();
}

class _ChatIndividualPageState extends State<ChatIndividualPage> {
  final TextEditingController _messageController = TextEditingController();
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();
  Timer? _timer;
  List<Message> _messages = [];
  StreamSubscription<List<Message>>? _subscription;
  ChatRoomData? _chatRoomData;
  late bool _showScrollToBottom;
  double _scrollOffset = 0;

  @override
  void initState() {
    _schedulePeriodicUpdate();
    _subscribeToChat();
    _getChatRoomData();
    _showScrollToBottom = (widget.messageIdToScrollTo == null) ? false : true;
    _scrollOffsetTracker();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _schedulePeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      msg!.checkForMessageUpdatesATProto(widget.id);
    });
  }

  void _subscribeToChat() {
    _subscription?.cancel(); // Cancel any existing subscription
    _subscription = msg!.subscribeChat(widget.id).listen((newMessages) {
      setState(() {
        _messages = newMessages;
      });
    });
  }

  void _getChatRoomData() async {
    await msg!.getChatRoomFromChatID(widget.id).then((val) => setState(() {
          _chatRoomData = val;
        }));
  }

  void _scrollToBottom() {
    if (_scrollController.isAttached) {
      if (_scrollOffset < 0) {
        _scrollOffset = 0;
      }
      setState(() {
        _showScrollToBottom = false;
      });
      _scrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
      );
    }
  }

  void _sendmsg() async {
    await msg!.sendMessage(_messageController.text, widget.id,
        (await msg!.getSenderFromDID(did!)));
    _messageController.clear();
    _scrollToBottom();
  }

  // tracks offset and tells widget when to show scrool to bottom button
  void _scrollOffsetTracker() {
    _scrollOffsetListener.changes.listen(
      (changeInPosition) {
        final positionPrev = _scrollOffset;
        _scrollOffset += (changeInPosition);
        // If position is above the cutoff and it previously wasn't, show scroll to bottom
        // and the opposite.
        if ((positionPrev < 500 && _scrollOffset > 500)) {
          setState(() {
            _showScrollToBottom = true;
          });
        } else if ((positionPrev > 500 && _scrollOffset < 500)) {
          setState(() {
            _showScrollToBottom = false;
          });
        }
      },
    );
  }

  // void _pickAndSendPhoto() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     msg!.sendImage(_messageController.text, widget.id,
  //         (await msg!.getSenderFromDID(did!)), image);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (_chatRoomData == null)
            ? const CircularProgressIndicator()
            : Row(
                children: [
                  avatarFromMembersJSON(jsonDecode(_chatRoomData!.members)),
                  const SizedBox(width: 8),
                  Text(handleFromMembersJSON(jsonDecode(_chatRoomData!.members),
                      _chatRoomData!.members.isNotEmpty)),
                ],
              ),
        leading: backButton(context),
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Center(
        child: SizedBox(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // The message view
                    _messages.isNotEmpty
                        ? ScrollablePositionedList.builder(
                            itemCount: _messages.length,
                            itemScrollController: _scrollController,
                            scrollOffsetListener: _scrollOffsetListener,
                            reverse: true,
                            initialScrollIndex: (widget.messageIdToScrollTo !=
                                        null &&
                                    _messages.isNotEmpty)
                                ? _messages.indexWhere((message) =>
                                    message.id == widget.messageIdToScrollTo)
                                : 0,
                            itemBuilder: (context, index) {
                              if (index >= 0) {
                                final message = _messages[index];
                                return buildMessageItem(message,
                                    const AlwaysStoppedAnimation(1.0), context);
                              } else {
                                return Container();
                              }
                            },
                          )
                        : Container(),
                    // Scroll to bottom icon
                    _showScrollToBottom
                        ? Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:
                                    Theme.of(context).cardColor.withOpacity(.5),
                              ),
                              child: IconButton(
                                  onPressed: () => _scrollToBottom(),
                                  icon: const Icon(Icons
                                      .keyboard_double_arrow_down_outlined)),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // TODO: add image support once I get streams
                    // IconButton(
                    //     onPressed: _pickAndSendPhoto,
                    //     icon: const Icon(Icons.add_photo_alternate_outlined)),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _sendmsg(),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _sendmsg()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
