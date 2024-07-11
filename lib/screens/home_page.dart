import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_split_view/flutter_split_view.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:vup_chat/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedChatId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplitView.material(
        childWidth: (250.h > 400) ? 250.h : 400,
        breakpoint: 450.h,
        placeholder: const ProfilePage(),
        child: const ChatListPage(),
      ),
    );
  }
}
