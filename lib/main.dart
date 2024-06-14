import 'package:bluesky/bluesky.dart';
import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/theme.dart';
import 'package:vup_chat/widgets/init_router.dart';

const FlutterSecureStorage storage = FlutterSecureStorage();
Bluesky? session;
BlueskyChat? chatSession;
String? did;

void main() async {
  // grab login credentials and try to log in
  WidgetsFlutterBinding.ensureInitialized();
  session = await tryLogIn(null, null);

  runApp(const VupChat());
}

class VupChat extends StatefulWidget {
  const VupChat({super.key});

  @override
  VupChatState createState() => VupChatState();
}

class VupChatState extends State<VupChat> {
  final ThemeMode _themeMode = ThemeMode.system;

  // void _toggleTheme() {
  //   setState(() {
  //     _themeMode =
  //         _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          title: 'Vup Chat',
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: _themeMode,
          debugShowCheckedModeBanner: false,
          home: const InitRouter(),
        );
      },
    );
  }
}
