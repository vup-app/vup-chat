import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vup_chat/functions/mls.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/screens/profile_page.dart';
import 'package:vup_chat/screens/s5_login_page.dart';
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
  List<ChatRoom> _chats = [];
  final Set<String> _selectedChatIds = {};
  StreamSubscription<List<ChatRoom>>? _subscription;
  List<Message>? _searchedMessages;
  List<ChatRoom>? _searchedChats;
  int? numHiddenChats;
  bool hiddenChatToggle = false;
  bool _shouldNagForMLS = false;

  @override
  void initState() {
    _checkIfS5LoggedIn();
    _checkIfShouldNagToAnnounceMLS();
    _subscribeToChatList();
    _textController.addListener(_onSearchChanged);
    super.initState();
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
        _checkForHiddenChats();
      }
    });
  }

  // Listener to search on search changed
  void _onSearchChanged() {
    if (_textController.text.isNotEmpty) {
      // not specifying chat room ID to search all possible rooms
      msg.searchMessages(_textController.text, null).then(
        (msgs) {
          setState(() {
            _searchedMessages = msgs;
          });
        },
      );
      msg.searchChatRooms(_textController.text).then((chats) {
        setState(() {
          _searchedChats = chats;
        });
      });
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
    msg.toggleChatHidden(_selectedChatIds.toList());
    setState(() {
      _chats.removeWhere((chat) => _selectedChatIds.contains(chat.id));
      _selectedChatIds.clear();
    });
  }

  // Optional ChatID is for when using the 3 button menu
  void _muteSelectedChats(String? optionalChatID) {
    if (optionalChatID != null) _selectedChatIds.add(optionalChatID);
    msg.toggleChatMutes(_selectedChatIds.toList());
    setState(() {
      _selectedChatIds.clear();
    });
  }

  // Optional ChatID is for when using the 3 button menu
  void _pinSelectedChats(String? optionalChatID) {
    if (optionalChatID != null) _selectedChatIds.add(optionalChatID);
    msg.toggleChatPin(_selectedChatIds.toList());
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _checkForHiddenChats() {
    int acc = 0;
    for (ChatRoom chat in _chats) {
      if (chat.hidden) acc++;
    }
    numHiddenChats = acc;
    if (numHiddenChats == 0) {
      setState(() {
        hiddenChatToggle = false;
      });
    }
  }

  void _checkIfS5LoggedIn() async {
    String? seed = await secureStorage.read(key: "seed");
    bool? s5Disabled = preferences.getBool("disable-s5");
    if ((s5Disabled == null || s5Disabled == false) && seed == null) {
      if (!context.mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => const S5LoginPage(),
      ))
          // Should check after login so on first login it will nag
          .then((_) async {
        _checkIfShouldNagToAnnounceMLS();
      });
    }
  }

  // Checks criteria to see if it should nag the user to enable MLS
  // (encrypted messages)
  void _checkIfShouldNagToAnnounceMLS() async {
    // wait for DID to not be null
    while (did == null) {
      await Future.delayed(Durations.long2);
    }
    // Conditions to nag
    // IF:
    // - S5 is enabled
    // - The user has not disabled MLS
    // - MLS keypair & pubkey are not yet announced to ATProto
    bool? mlsDisabled = preferences.getBool("disable-mls");
    // Check criteria 1-2 to not make unecesary network calls
    if (msg.s5 != null &&
        msg.s5!.hasIdentity &&
        (mlsDisabled == null || mlsDisabled == false) &&
        did != null) {
      try {
        await updateOwnMLSRecord();
      } catch (e) {
        logger.d(e);
        // TODO: this is a bad way of error handling
        if (e.toString().contains("400")) {
          setState(() {
            _shouldNagForMLS = true;
          });
          logger.d("activating nag mode");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
                      Tooltip(
                        message: "Toggle Chat Pin",
                        child: IconButton(
                          icon: const Icon(Icons.push_pin_outlined),
                          onPressed: () => _pinSelectedChats(null),
                        ),
                      )
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
                // Here is the banner that nags the user to enable encryped chats
                // This section swaps views if search is happening or not
                (_shouldNagForMLS)
                    ? MaterialBanner(
                        content: const Text("Enable encrypted messages"),
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        actions: [
                            TextButton(
                                onPressed: () {
                                  disableMLS();
                                  _checkIfShouldNagToAnnounceMLS();
                                },
                                child: const Text("Disable")),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _shouldNagForMLS = false;
                                  });
                                },
                                child: const Text("Dismiss")),
                            TextButton(
                                onPressed: () async {
                                  setState(() {
                                    _shouldNagForMLS = false;
                                  });
                                  await enableMLS();
                                  _checkIfShouldNagToAnnounceMLS();
                                },
                                child: const Text("Enable")),
                          ])
                    : Container(),
                (_textController.text.isNotEmpty &&
                        _searchedMessages != null &&
                        _searchedChats != null)
                    // But if the search does contain something, it shows the search view
                    ? (_searchedMessages!.isEmpty)
                        ? const Text("Crickets...")
                        : Expanded(
                            child: ListView(
                            children: [
                              const Text("Group names"),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchedChats!.length,
                                itemBuilder: (context, index) {
                                  return ChatRoomSearchGroupItem(
                                      chatRoom: _searchedChats![index]);
                                },
                              ),
                              const Text("Messages"),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchedMessages!.length,
                                itemBuilder: (context, index) {
                                  return ChatRoomSearchMessageItem(
                                      message: _searchedMessages![index]);
                                },
                              )
                            ],
                          ))
                    // So if the search doesn't contain text it just shows chats
                    : ChatRoomList(
                        chats: _chats,
                        onChatItemSelection: _onChatItemSelection,
                        selectedChatIds: _selectedChatIds,
                        hideSelectedChats: _hideSelectedChats,
                        toggleNotificationsSelectedChats: _muteSelectedChats,
                        togglePinSelectedChats: _pinSelectedChats,
                        hiddenChatToggle: hiddenChatToggle,
                      ),
              ],
            )));
  }
}
