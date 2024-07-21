import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/messenger/database.dart';
import 'package:vup_chat/widgets/chat_page_list_item.dart';

class ChatRoomList extends StatefulWidget {
  final List<ChatRoom> chats;
  final Function(String) onChatItemSelection;
  final Function(String?) hideSelectedChats;
  final Function(String?) toggleNotificationsSelectedChats;
  final Set<String> selectedChatIds;
  final bool hiddenChatToggle;

  const ChatRoomList({
    super.key,
    required this.chats,
    required this.onChatItemSelection,
    required this.hideSelectedChats,
    required this.toggleNotificationsSelectedChats,
    required this.selectedChatIds,
    required this.hiddenChatToggle,
  });

  @override
  ChatRoomListState createState() => ChatRoomListState();
}

class ChatRoomListState extends State<ChatRoomList> {
  String? hoveredChatId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ImplicitlyAnimatedList<ChatRoom>(
        items: widget.chats,
        areItemsTheSame: (a, b) =>
            (a.lastMessage == b.lastMessage && a.id == b.id),
        itemBuilder: (context, animation, item, index) {
          if (item.hidden == widget.hiddenChatToggle) {
            return GestureDetector(
              onLongPress: () => widget.onChatItemSelection(item.id),
              onTap: () => (widget.selectedChatIds.isNotEmpty)
                  ? widget.onChatItemSelection(item.id)
                  : null,
              child: MouseRegion(
                onEnter: (_) => setState(() => hoveredChatId = item.id),
                onExit: (_) => setState(() => hoveredChatId = null),
                child: Stack(
                  children: [
                    SizeFadeTransition(
                        sizeFraction: 0.7,
                        curve: Curves.easeInOut,
                        animation: animation,
                        child: ChatRoomListItem(
                          chat: item,
                          animation: animation,
                          selectedItems: widget.selectedChatIds,
                          onItemPressed: widget.onChatItemSelection,
                        )),
                    if (widget.selectedChatIds.contains(item.id))
                      Positioned.fill(
                        child: Container(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    Positioned(
                      right: 8.0,
                      top: 8.0,
                      child: AnimatedOpacity(
                        opacity: hoveredChatId == item.id ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            // Handle menu item selection
                            if (value == 'Toggle Notifications') {
                              widget.toggleNotificationsSelectedChats(item.id);
                            } else if (value == "Hide Message") {
                              widget.hideSelectedChats(item.id);
                            }
                          },
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Toggle Notifications',
                                child: ListTile(
                                  leading: Icon(Icons.edit_notifications),
                                  title: Text('Toggle Notifications'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Hide Message',
                                child: ListTile(
                                  leading: Icon(Icons.archive_outlined),
                                  title: Text('Hide Message'),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
        removeItemBuilder: (context, animation, oldItem) {
          return FadeTransition(
              opacity: animation,
              child: ChatRoomListItem(
                chat: oldItem,
                animation: animation,
                selectedItems: widget.selectedChatIds,
                onItemPressed: widget.onChatItemSelection,
              ));
        },
      ),
    );
  }
}
