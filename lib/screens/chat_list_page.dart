import 'dart:async';
import 'dart:convert';

import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/search_actor.page.dart';
import 'package:vup_chat/widgets/chat_page_list_item.dart';

class ChatListPage extends StatefulWidget {
  final void Function(ConvoView convo)? onChatSelected;

  const ChatListPage({super.key, this.onChatSelected});

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late Future<ListConvosOutput?> _futureConvos;
  Timer? _timer;
  List<ConvoView> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadCachedConversations();
    _loadConversations();
    _schedulePeriodicUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _futureConvos = getChatTimeline();
    });

    ListConvosOutput? result = await _futureConvos;

    if (result != null) {
      final newConversations = result.convos;
      _updateConversations(newConversations);

      // Save to secure storage
      await storage.write(key: 'conversations', value: jsonEncode(result));
    }
  }

  void _updateConversations(List<ConvoView> newConversations) {
    final oldConversations = _conversations;

    for (var i = 0; i < oldConversations.length; i++) {
      if (i < newConversations.length) {
        if (oldConversations[i].id != newConversations[i].id) {
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => buildChatListPageListItem(
                oldConversations[i], animation, context, widget.onChatSelected),
            duration: const Duration(milliseconds: 300),
          );
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 300),
          );
        }
      } else {
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => buildChatListPageListItem(
              oldConversations[i], animation, context, widget.onChatSelected),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    for (var i = oldConversations.length; i < newConversations.length; i++) {
      _listKey.currentState
          ?.insertItem(i, duration: const Duration(milliseconds: 300));
    }

    _conversations = newConversations;
  }

  Future<void> _loadCachedConversations() async {
    String? cachedData = await storage.read(key: 'conversations');
    if (cachedData != null) {
      ListConvosOutput cachedConvos =
          ListConvosOutput.fromJson(jsonDecode(cachedData));
      setState(() {
        _conversations = cachedConvos.convos;
      });
    }
  }

  void _schedulePeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadConversations();
    });
  }

  Future<void> refreshConversations() async {
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message_outlined),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SearchActorPage()));
        },
      ),
      body: FutureBuilder<ListConvosOutput?>(
        future: _futureConvos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_conversations.isEmpty) {
            return const Center(child: Text('No conversations found.'));
          }

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshConversations,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _conversations.length,
              itemBuilder: (context, index, animation) {
                final convo = _conversations[index];
                return buildChatListPageListItem(
                    convo, animation, context, widget.onChatSelected);
              },
            ),
          );
        },
      ),
    );
  }
}
