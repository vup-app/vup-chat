import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/login_page.dart';
import 'package:vup_chat/screens/place_holder_page.dart';

class InitRouter extends StatefulWidget {
  const InitRouter({super.key});

  @override
  State<InitRouter> createState() => _InitRouterState();
}

class _InitRouterState extends State<InitRouter> {
  bool? loggedIn;
  @override
  void initState() {
    loggedIn = preferences.getBool("logged-in");
    _initBackend();
    super.initState();
  }

  Future<void> _initBackend() async {
    // this should refresh state when init is done to allow drawing of things that
    // need did, etc
    msg.init();
  }

  @override
  Widget build(BuildContext context) {
    // If it doesn't remember logging in, send to the login page
    if (loggedIn == null || loggedIn == false) {
      return const LoginPage();
    } else {
      // if msgcore has been initialized, then send to the chatlist page
      return BasedSplitView(
        navigatorKey: vupSplitViewKey,
        leftWidget: ChatListPage(
          key: leftKey,
        ),
        rightPlaceholder: const PlaceHolderPage(),
      );
      // Else display a shimmer until it's done
    }
  }
}
