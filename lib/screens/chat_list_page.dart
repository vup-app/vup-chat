import 'dart:async';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/profile_page.dart';
import 'package:vup_chat/screens/search_actor.page.dart';
import 'package:vup_chat/screens/settings_page.dart';
import 'package:vup_chat/widgets/chat_page_list_item.dart';
import 'package:vup_chat/widgets/search_bar_chats.dart';

class ChatListPage extends StatefulWidget {
  final HomeRoutingService? homeRoutingService;

  const ChatListPage({super.key, this.homeRoutingService});

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  final TextEditingController _textController = TextEditingController();
  List<ChatRoomData> _chats = [];
  final Set<String> _selectedChatIds = {};
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
      if (newChats != _chats) {
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

  void onChatItemSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  void _deleteSelectedChats() {
    // Implement delete logic here
    setState(() {
      _chats.removeWhere((chat) => _selectedChatIds.contains(chat.id));
      _selectedChatIds.clear();
    });
  }

  void _muteSelectedChats() {
    msg.toggleChatMutes(_selectedChatIds.toList());
    setState(() {
      _selectedChatIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedChatIds.isNotEmpty
            ? AppBar(
                title: Text('${_selectedChatIds.length} selected'),
                leading: InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    setState(() {
                      _selectedChatIds.clear();
                    });
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedChats,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_notifications_outlined),
                    onPressed: _muteSelectedChats,
                  ),
                ],
              )
            : null,
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
            chatsSearchBar(_textController, _navToSettings, _navToProfile),
            // This section swaps views if search is happening or not
            (_textController.text.isNotEmpty && _searchedMessages != null)
                // But if the search does contain something, it shows the search view
                ? (_searchedMessages!.isEmpty)
                    ? const Text("Crickets...")
                    : Expanded(
                        child: ListView.builder(
                        itemCount: _searchedMessages!.length,
                        itemBuilder: (context, index) {
                          return Provider(
                            create: (context) => _selectedChatIds,
                            child: buildChatRoomSearchItemMessage(
                                _searchedMessages![index],
                                context,
                                widget.homeRoutingService),
                          );
                        },
                      ))
                // So if the search doesn't contain text it just shows chats
                : Expanded(
                    child: ImplicitlyAnimatedList<ChatRoomData>(
                      items: _chats,
                      areItemsTheSame: (a, b) =>
                          (a.lastMessage == b.lastMessage && a.id == b.id),
                      itemBuilder: (context, animation, item, index) {
                        return GestureDetector(
                          onLongPress: () => onChatItemSelection(item.id),
                          child: MouseRegion(
                            onEnter: (_) {
                              // Show icon on hover (desktop)
                              // You may need to use a state variable to manage hover state
                            },
                            onExit: (_) {
                              // Hide icon on hover exit (desktop)
                              // You may need to use a state variable to manage hover state
                            },
                            child: Stack(
                              children: [
                                SizeFadeTransition(
                                  sizeFraction: 0.7,
                                  curve: Curves.easeInOut,
                                  animation: animation,
                                  child: buildChatRoomListItem(
                                    item,
                                    animation,
                                    context,
                                    widget.homeRoutingService,
                                    _selectedChatIds,
                                    onChatItemSelection,
                                  ),
                                ),
                                if (_selectedChatIds.contains(item.id))
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                // TODO: Add hover
                                // Add hover icon here
                                // if (/* hover condition */)
                                //   Positioned(
                                //     right: 8,
                                //     top: 8,
                                //     child: IconButton(
                                //       icon: const Icon(Icons.more_vert),
                                //       onPressed: () {
                                //         // Show options like delete or mute
                                //       },
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                        );
                      },
                      removeItemBuilder: (context, animation, oldItem) {
                        return FadeTransition(
                          opacity: animation,
                          child: buildChatRoomListItem(
                            oldItem,
                            animation,
                            context,
                            widget.homeRoutingService,
                            _selectedChatIds,
                            onChatItemSelection,
                          ),
                        );
                      },
                    ),
                  )
          ],
        ));
  }
}
