import 'dart:async';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final TextEditingController _textController = TextEditingController();
  List<ChatRoomData> _chats = [];
  StreamSubscription<List<ChatRoomData>>? _subscription;
  List<Message>? _searchedMessages;

  @override
  void initState() {
    super.initState();
    _subscribeToChatList();
    _textController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _textController.removeListener(_onSearchChanged);
    _textController.dispose();
    super.dispose();
  }

  void _subscribeToChatList() {
    _subscription = msg.subscribeChatRoom().listen((newChats) {
      if (!_listsAreEqual(_chats, newChats)) {
        setState(() {
          _chats = newChats;
        });
      }
    });
  }

  // Listener to search on search changed
  void _onSearchChanged() {
    if (_textController.text.isNotEmpty) {
      msg.searchMessages(_textController.text, null).then(
        (msgs) {
          setState(() {
            _searchedMessages = msgs;
          });
        },
      ); // not specifying chat room ID
    } else {
      setState(() {});
    }
  }

  bool _listsAreEqual(List<ChatRoomData> oldList, List<ChatRoomData> newList) {
    if (oldList.length != newList.length) return false;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id) return false;
    }
    return true;
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
        body: Column(
          children: [
            // This is a complicated search bar
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.h),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.h),
                      borderSide: BorderSide(
                        width: 1.h,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.h),
                      borderSide: BorderSide(
                        width: 1.h,
                      ),
                    ),
                    prefixIcon: (_textController.text.isEmpty)
                        ? const Icon(Icons.search)
                        : InkWell(
                            child: const Icon(Icons.clear),
                            onTap: () {
                              _textController.clear();
                            },
                          ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 0.h),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          // Handle menu item selection
                          if (value == 'Settings') {
                            _navToSettings();
                          } else if (value == 'Profile') {
                            _navToProfile();
                          }
                        },
                        icon: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Settings',
                              child: ListTile(
                                leading: Icon(Icons.settings),
                                title: Text('Settings'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Profile',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Profile'),
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                    hintText: 'Search...',
                  ),
                ),
              ),
            ),
            // This section swaps views if search is happening or not
            (_textController.text.isNotEmpty && _searchedMessages != null)
                // But if the search does contain something, it shows the search view
                ? (_searchedMessages!.isEmpty)
                    ? const Text("Crickets...")
                    : Expanded(
                        child: ListView.builder(
                        itemCount: _searchedMessages!.length,
                        itemBuilder: (context, index) {
                          return buildChatRoomSearchItemMessage(
                              _searchedMessages![index],
                              context,
                              widget.homeRoutingService);
                        },
                      ))
                // So if the search doesn't contain text it just shows chats
                : Expanded(
                    child: ImplicitlyAnimatedList<ChatRoomData>(
                      items: _chats,
                      areItemsTheSame: (a, b) =>
                          (a.lastMessage == b.lastMessage && a.id == b.id),
                      itemBuilder: (context, animation, item, index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: buildChatRoomListItem(item, animation, context,
                              widget.homeRoutingService),
                        );
                      },
                      removeItemBuilder: (context, animation, oldItem) {
                        return FadeTransition(
                          opacity: animation,
                          child: buildChatRoomListItem(oldItem, animation,
                              context, widget.homeRoutingService),
                        );
                      },
                    ),
                  )
          ],
        ));
  }
}
