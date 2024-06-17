import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/constants.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/profile_page.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/screens/search_actor.page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    ChatListPage(),
    ProfilePage(),
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;
  Widget leftWidget = const ChatListPage(onChatSelected: null);
  Widget rightWidget = const ProfilePage();
  String? selectedChatId;

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
      if (index == 0) {
        rightWidget = const ProfilePage();
      }
    });
  }

  void _onChatSelected(ConvoView convo) {
    setState(() {
      selectedChatId = convo.id;
      rightWidget = ChatIndividualPage(
        id: convo.id,
        otherName: convo.members.map((m) => m.displayName).last ?? "null",
        avatar: convo.members.last.avatar != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(convo.members.last.avatar!),
              )
            : const CircleAvatar(child: Icon(Icons.person)),
      );
    });
  }

  void _onNewChatSelected() {
    setState(() {
      rightWidget = const SearchActorPage();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.minWidth / 2 > horizontalCutoff) {
          return Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ChatListPage(
                    onChatSelected: _onChatSelected,
                    onNewChatSelected: _onNewChatSelected,
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  flex: 2,
                  child: rightWidget,
                ),
              ],
            ),
          );
        } else {
          // Mobile Layout
          return Scaffold(
            body: HomePage._widgetOptions.elementAt(_index),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w600),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  label: "Chats",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  label: "Profile",
                ),
              ],
              currentIndex: _index,
              onTap: _onItemTapped,
            ),
          );
        }
      },
    );
  }
}
