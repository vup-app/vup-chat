import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/home_page.dart';
import 'package:vup_chat/screens/login_page.dart';
import 'package:vup_chat/screens/place_holder_page.dart';

class InitRouter extends StatefulWidget {
  const InitRouter({super.key});

  @override
  State<InitRouter> createState() => _InitRouterState();
}

class _InitRouterState extends State<InitRouter> {
  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const LoginPage();
    } else {
      return BasedSplitView(
        navigatorKey: vupSplitViewKey,
        leftWidget: HomePage(
          key: leftKey,
        ),
        rightPlaceholder: const PlaceHolderPage(),
      );
    }
  }
}
