import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:bluesky_chat/bluesky_chat.dart';

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
  List<MessageView> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCachedMessages();
    _loadMessages();
    _schedulePeriodicUpdate();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (chatSession != null) {
      GetMessagesOutput? result =
          (await chatSession!.convo.getMessages(convoId: widget.id)).data;
      List<MessageView> newMessages = result.messages
          .map((messageView) => MessageView.fromJson(messageView.toJson()))
          .toList();
      if (!listEquals(_messages, newMessages)) {
        setState(() {
          _messages = newMessages;
          _cacheMessages();
        });
        // TODO: Make this only happen when near bottom of messages
        _scrollToBottom();
      }
    }
  }

  void _schedulePeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadMessages();
    });
  }

  Future<void> _cacheMessages() async {
    await storage.write(
        key: 'messages_${widget.id}',
        value: jsonEncode(_messages.map((m) => m.toJson()).toList()));
  }

  Future<void> _loadCachedMessages() async {
    String? cachedData = await storage.read(key: 'messages_${widget.id}');
    if (cachedData != null) {
      List<dynamic> cachedJson = jsonDecode(cachedData);
      List<MessageView> cachedMessages =
          cachedJson.map((json) => MessageView.fromJson(json)).toList();
      setState(() {
        _messages = cachedMessages;
      });
      _jumpToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut);
    } else {
      Timer(const Duration(milliseconds: 200), () => _scrollToBottom());
    }
  }

  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Make this not look like it's scrolling (Maybe build from bottom up?)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.avatar,
            const SizedBox(width: 8),
            Text(widget.otherName),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast),
              controller: _scrollController,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message.sender.did == did;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Text copied to clipboard')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
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
                      sendMessage(_messageController.text, widget.id);
                      _messageController.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text, widget.id);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
