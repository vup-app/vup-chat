import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/profile_page.dart';
import 'package:vup_chat/screens/search_actor.page.dart';
import 'package:vup_chat/screens/settings_page.dart';
import 'package:vup_chat/widgets/chat_page_list_item.dart';
import 'package:vup_chat/widgets/chat_room_list.dart';
import 'package:vup_chat/widgets/search_bar_chats.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  ChatListPageState createState() => ChatListPageState();
}

class ChatListPageState extends State<ChatListPage> {
  final TextEditingController _textController = TextEditingController();
  List<ChatRoomData> _chats = [];
  final Set<String> _selectedChatIds = {};
  StreamSubscription<List<ChatRoomData>>? _subscription;
  List<Message>? _searchedMessages;
  int? numHiddenChats;
  bool hiddenChatToggle = false;

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
    _subscription = msg!.subscribeChatRoom().listen((newChats) {
      if (newChats != _chats) {
        setState(() {
          _chats = newChats;
        });
        _checkForHiddenChats();
      }
    });
  }

  // Listener to search on search changed
  void _onSearchChanged() {
    if (_textController.text.isNotEmpty) {
      msg!.searchMessages(_textController.text, null).then(
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
    vupSplitViewKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SettingsPage()),
        (Route<dynamic> route) => route.isFirst);
  }

  void _navToProfile() async {
    vupSplitViewKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProfilePage()),
        (Route<dynamic> route) => route.isFirst);
  }

  // TODO: Make it deselect on another press
  void _onChatItemSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  // Optional ChatID is for when using the 3 button menu
  void _hideSelectedChats(String? optionalChatID) {
    if (optionalChatID != null) _selectedChatIds.add(optionalChatID);
    msg!.toggleChatHidden(_selectedChatIds.toList());
    setState(() {
      _chats.removeWhere((chat) => _selectedChatIds.contains(chat.id));
      _selectedChatIds.clear();
    });
  }

  // Optional ChatID is for when using the 3 button menu
  void _muteSelectedChats(String? optionalChatID) {
    if (optionalChatID != null) _selectedChatIds.add(optionalChatID);
    msg!.toggleChatMutes(_selectedChatIds.toList());
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _checkForHiddenChats() {
    int acc = 0;
    for (ChatRoomData chat in _chats) {
      if (chat.hidden) acc++;
    }
    numHiddenChats = acc;
    if (numHiddenChats == 0) {
      setState(() {
        hiddenChatToggle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Defines app bar at top
        appBar: _selectedChatIds.isNotEmpty
            ? AppBar(
                title: Text('${_selectedChatIds.length} selected'),
                leading: Tooltip(
                  message: "Clear Selection",
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _selectedChatIds.clear();
                    }),
                  ),
                ),
                actions: [
                  Tooltip(
                    message: "Hide Chat",
                    child: IconButton(
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: () => _hideSelectedChats(null),
                    ),
                  ),
                  Tooltip(
                      message: "Toggle Chat Mute",
                      child: IconButton(
                        icon: const Icon(Icons.edit_notifications_outlined),
                        onPressed: () => _muteSelectedChats(null),
                      )),
                ],
              )
            : null,
        // This defines the "new chat" prompt in the bototm right
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.message_outlined),
          onPressed: () {
            vupSplitViewKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const SearchActorPage()),
                (Route<dynamic> route) => route.isFirst);
          },
        ),
        // Then we have the body contents
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // This is a complicated search bar
            chatsSearchBar(_textController, _navToSettings, _navToProfile),
            // Shows bar to show hidden chats if selected
            (numHiddenChats != null && numHiddenChats! > 0)
                ? Container(
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      leading: const Icon(Icons.archive),
                      title: (numHiddenChats == 1)
                          ? const Text("You have 1 hidden chat.")
                          : Text("You have $numHiddenChats hidden chats."),
                      trailing: Switch(
                        value: hiddenChatToggle,
                        onChanged: (value) {
                          setState(() {
                            hiddenChatToggle = !hiddenChatToggle;
                          });
                        },
                      ),
                    ),
                  )
                : Container(),
            // This section swaps views if search is happening or not
            (_textController.text.isNotEmpty && _searchedMessages != null)
                // But if the search does contain something, it shows the search view
                ? (_searchedMessages!.isEmpty)
                    ? const Text("Crickets...")
                    : Expanded(
                        child: ListView.builder(
                        itemCount: _searchedMessages!.length,
                        itemBuilder: (context, index) {
                          return ChatRoomSearchItem(
                              message: _searchedMessages![index]);
                        },
                      ))
                // So if the search doesn't contain text it just shows chats
                : ChatRoomList(
                    chats: _chats,
                    onChatItemSelection: _onChatItemSelection,
                    selectedChatIds: _selectedChatIds,
                    hideSelectedChats: _hideSelectedChats,
                    toggleNotificationsSelectedChats: _muteSelectedChats,
                    hiddenChatToggle: hiddenChatToggle,
                  ),
          ],
        ));
  }
}
