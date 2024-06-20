import 'package:flutter/material.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/profile_page.dart';
import 'package:vup_chat/screens/search_actor.page.dart';
import 'package:vup_chat/screens/settings_page.dart';
import 'package:vup_chat/widgets/chat_page_list_item.dart';

class ChatListPage extends StatefulWidget {
  final HomeRoutingService? homeRoutingService;

  const ChatListPage({super.key, this.homeRoutingService});

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navToSettings() async {
    if (widget.homeRoutingService != null) {
      widget.homeRoutingService!.navigateToSettings();
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPage()));
    }
  }

  void _navToProfile() async {
    if (widget.homeRoutingService != null) {
      widget.homeRoutingService!.navigateToProfile();
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfilePage()));
    }
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        reverse: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              _navToSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              _navToProfile();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message_outlined),
        onPressed: () {
          if (widget.homeRoutingService != null) {
            widget.homeRoutingService!.onNewChatSelected();
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchActorPage()));
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
      ),
      drawer: _buildDrawer(),
      body: StreamBuilder<List<ChatListData>>(
        stream: msg.subscribeChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          }

          final chats = snapshot.data ?? [];
          return AnimatedList(
            key: _listKey,
            initialItemCount: chats.length,
            itemBuilder: (context, index, animation) {
              final chat = chats[index];
              return buildChatListPageListItem(
                  chat, animation, context, widget.homeRoutingService);
            },
          );
        },
      ),
    );
  }
}
