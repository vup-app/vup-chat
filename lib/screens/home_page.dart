import 'package:flutter/material.dart';
import 'package:vup_chat/functions/general.dart';
import 'package:vup_chat/functions/home_routing_service.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget leftWidget = const ChatListPage(homeRoutingService: null);
  Widget rightWidget = const ProfilePage();
  String? selectedChatId;
  late HomeRoutingService homeRoutingService;

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
              child: Container(
                key: ValueKey(rightWidget), // unique key to fix state issues
                child: rightWidget,
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout
      return const Scaffold(body: ChatListPage());
    }
  }
}
