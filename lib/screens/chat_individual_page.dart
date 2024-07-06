import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  Timer? _timer;
  List<Message> _messages = [];
  StreamSubscription<List<Message>>? _subscription;
  ChatRoomData? _chatRoomData;

  @override
  void initState() {
    super.initState();
    _schedulePeriodicUpdate();
    _subscribeToChat();
    _getChatRoomData();
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
      // (widget.messageIdToScrollTo == null)
      //     ? _scrollToBottom()
      //     : _scrollToMessage(widget.messageIdToScrollTo);
    });
  }

  void _getChatRoomData() async {
    await msg!.getChatRoomFromChatID(widget.id).then((val) => setState(() {
          _chatRoomData = val;
        }));
  }

  // void _scrollToMessage(String? messageId) {
  //   if (messageId != null) {
  //     final index = ;
  //     if (index != 0) {
  //       _scrollController.scrollTo(
  //         index: index,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeInOut,
  //       );
  //     }
  //   }
  // }

  // void _scrollToBottom() {
  //   if (_scrollController.isAttached) {
  //     _scrollController.scrollTo(
  //       index: 0,
  //       duration: const Duration(milliseconds: 200),
  //       curve: Curves.elasticOut,
  //     );
  //   } else {
  //     Timer(const Duration(milliseconds: 200), () => _scrollToBottom());
  //   }
  // }

  void _sendmsg() async {
    await msg!.sendMessage(_messageController.text, widget.id,
        (await msg!.getSenderFromDID(did!)));
    _messageController.clear();
  }

  void _pickAndSendPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      msg!.sendImage(_messageController.text, widget.id,
          (await msg!.getSenderFromDID(did!)), image);
    }
  }

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
                child: ScrollablePositionedList.builder(
                  itemCount: 1,
                  itemScrollController: _scrollController,
                  itemPositionsListener: _itemPositionsListener,
                  reverse: true,
                  initialScrollIndex: (widget.messageIdToScrollTo != null &&
                          _messages.isNotEmpty)
                      ? _messages.indexWhere(
                          (message) => message.id == widget.messageIdToScrollTo)
                      : 0,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return buildMessageItem(
                        message, const AlwaysStoppedAnimation(1.0), context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: _pickAndSendPhoto,
                        icon: const Icon(Icons.add_photo_alternate_outlined)),
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
