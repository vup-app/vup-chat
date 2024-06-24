import 'dart:async';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/app_bar_back.dart';

class ChatIndividualPage extends StatefulWidget {
  final String id;
  final CircleAvatar avatar;
  final String otherName;

  const ChatIndividualPage({
    super.key,
    required this.id,
    required this.avatar,
    required this.otherName,
  });

  @override
  State<ChatIndividualPage> createState() => _ChatIndividualPageState();
}

class _ChatIndividualPageState extends State<ChatIndividualPage> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ScrollController _scrollController;
  Timer? _timer;
  List<Message> _messages = [];
  StreamSubscription<List<Message>>? _subscription;

  @override
  void initState() {
    super.initState();
    _schedulePeriodicUpdate();
    _scrollController = ScrollController();
    _subscribeToChat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
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
      _updateAnimatedList(_messages, newMessages);
      setState(() {
        _messages = newMessages;
      });
      _scrollToBottom();
    });
  }

  void _updateAnimatedList(
      List<Message> oldMessages, List<Message> newMessages) {
    final oldCount = oldMessages.length;
    final newCount = newMessages.length;

    if (newCount > oldCount) {
      for (var i = oldCount; i < newCount; i++) {
        _listKey.currentState?.insertItem(i);
      }
    } else if (newCount < oldCount) {
      for (var i = oldCount - 1; i >= newCount; i--) {
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildMessageItem(oldMessages[i], animation),
        );
      }
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
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
    logger.d("user ${widget.otherName}");
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
                child: ImplicitlyAnimatedList<Message>(
                  items: _messages,
                  areItemsTheSame: (a, b) => (a.id == b.id),
                  reverse: true,
                  itemBuilder: (context, animation, item, index) {
                    return SizeFadeTransition(
                        sizeFraction: 0.7,
                        curve: Curves.easeInOut,
                        animation: animation,
                        child: _buildMessageItem(item, animation));
                  },
                  removeItemBuilder: (context, animation, oldItem) {
                    return FadeTransition(
                      opacity: animation,
                      child: _buildMessageItem(oldItem, animation),
                    );
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
                          msg.sendMessage(_messageController.text, widget.id);
                          _messageController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        msg.sendMessage(_messageController.text, widget.id);
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
