import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/home_page.dart';
import 'package:vup_chat/screens/login_page.dart';

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
      return const HomePage();
    }
  }
}
