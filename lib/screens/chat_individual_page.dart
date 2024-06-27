import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/app_bar_back.dart';

class ChatIndividualPage extends StatefulWidget {
  final String id;
  final CircleAvatar avatar;
  final String otherName;
  final String? messageIdToScrollTo; // Optional parameter

  const ChatIndividualPage({
    super.key,
    required this.id,
    required this.avatar,
    required this.otherName,
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

  @override
  void initState() {
    super.initState();
    _schedulePeriodicUpdate();
    _subscribeToChat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.messageIdToScrollTo != null) {
        _scrollToMessage(widget.messageIdToScrollTo!);
      }
    });
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
      msg.checkForMessageUpdatesATProto(widget.id);
    });
  }

  void _subscribeToChat() {
    _subscription?.cancel(); // Cancel any existing subscription
    _subscription = msg.subscribeChat(widget.id).listen((newMessages) {
      setState(() {
        _messages = newMessages;
      });
      _scrollToBottom();
    });
  }

  void _scrollToMessage(String messageId) {
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index != 0) {
      _scrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMessageItem(Message message, Animation<double> animation) {
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
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.isAttached) {
      _scrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
      );
    } else {
      Timer(const Duration(milliseconds: 200), () => _scrollToBottom());
    }
  }

  @override
  void didUpdateWidget(covariant ChatIndividualPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _subscribeToChat(); // Re-subscribe to chat messages with new ID
      _schedulePeriodicUpdate(); // Ensure periodic updates for the new chat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.avatar,
            const SizedBox(width: 8),
            Text(widget.otherName),
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
                  itemCount: _messages.length,
                  itemScrollController: _scrollController,
                  itemPositionsListener: _itemPositionsListener,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (index > -1) {
                      final message = _messages[index];
                      return _buildMessageItem(
                          message, const AlwaysStoppedAnimation(1.0));
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) {
                          msg.sendMessage(_messageController.text, widget.id,
                              Sender(did: did!, displayName: widget.otherName));
                          _messageController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        msg.sendMessage(_messageController.text, widget.id,
                            Sender(did: did!, displayName: widget.otherName));
                        _messageController.clear();
                      },
                    ),
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
