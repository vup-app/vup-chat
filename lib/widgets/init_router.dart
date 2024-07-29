import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/functions/s5.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/core.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/login_page.dart';
import 'package:vup_chat/screens/place_holder_page.dart';
import 'package:vup_chat/widgets/chat_list_page_placeholder.dart';

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
    try {
      session = await tryLogIn(null, null);
      s5 = await initS5();
    } catch (e) {
      logger.d("Failed to connect to an online session: $e");
    }
    setState(() {
      msg = MsgCore(s5: s5, bskySession: session, bskyChatSession: chatSession);
    });
    msg!.init();
  }

  @override
  Widget build(BuildContext context) {
    // If it doesn't remember logging in, send to the login page
    if (loggedIn == null || loggedIn == false) {
      return const LoginPage();
    } else {
      // if msgcore has been initialized, then send to the chatlist page
      if (msg != null) {
        return BasedSplitView(
          navigatorKey: vupSplitViewKey,
          leftWidget: ChatListPage(
            key: leftKey,
          ),
          rightPlaceholder: const PlaceHolderPage(),
        );
        // Else display a shimmer until it's done
      } else {
        return BasedSplitView(
          navigatorKey: vupSplitViewKey,
          leftWidget: ChatPlaceholderList(
            key: leftKey,
          ),
          rightPlaceholder: const PlaceHolderPage(),
        );
      }
    }
  }
}
