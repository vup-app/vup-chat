import 'package:flutter/material.dart';
import 'package:vup_chat/functions/general.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // static const List<Widget> _widgetOptions = <Widget>[
  //   ChatListPage(),
  //   ProfilePage(),
  //   SettingsPage(),
  // ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // var _index = 0;
  Widget leftWidget = const ChatListPage(homeRoutingService: null);
  Widget rightWidget = const ProfilePage();
  String? selectedChatId;
  late HomeRoutingService homeRoutingService;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _index = index;
  //     if (index == 0) {
  //       rightWidget = const ProfilePage();
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    homeRoutingService = HomeRoutingService(
      rightPanel: const ProfilePage(),
      onRightPanelChanged: (Widget newWidget) {
        setState(() {
          rightWidget = newWidget;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop()) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: ChatListPage(
                homeRoutingService: homeRoutingService,
              ),
            ),
            Expanded(
              flex: 2,
              child: rightWidget,
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout
      return const Scaffold(body: ChatListPage()
          // body: HomePage._widgetOptions.elementAt(_index),
          // bottomNavigationBar: BottomNavigationBar(
          //   selectedItemColor: Colors.green,
          //   unselectedItemColor: Colors.grey.shade600,
          //   selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          //   unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          //   type: BottomNavigationBarType.fixed,
          //   items: const [
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.message_outlined),
          //       label: "Chats",
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.account_circle_outlined),
          //       label: "Profile",
          //     ),
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.settings),
          //       label: "Settings",
          //     ),
          //   ],
          //   currentIndex: _index,
          //   onTap: _onItemTapped,
          // ),
          );
    }
  }
}
