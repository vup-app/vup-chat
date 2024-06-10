import 'package:flutter/material.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    ChatPage(),
    ProfilePage()
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage._widgetOptions.elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
}
