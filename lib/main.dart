import 'package:based_splash_page/based_splash_page.dart';
import 'package:based_split_view/based_split_view.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:s5/s5.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/functions/s5.dart';
import 'package:vup_chat/messenger/core.dart';
import 'package:vup_chat/screens/place_holder_page.dart';
import 'package:vup_chat/theme.dart';
import 'package:vup_chat/widgets/init_router.dart';
import 'package:flutter/src/widgets/image.dart' as img;

// TODO: Move these to providers and stop mucking about with
// global state
const FlutterSecureStorage storage = FlutterSecureStorage();
final Logger logger = Logger();
late SharedPreferences preferences;
final vupSplitViewKey = GlobalKey<NavigatorState>();
final _leftKey = GlobalKey();
MsgCore? msg;
Bluesky? session;
BlueskyChat? chatSession;
S5? s5;
String? did;

void main() async {
  // grab login credentials and try to log in
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Make app retry if entered on online mode
  try {
    session = await tryLogIn(null, null);
    preferences = await SharedPreferences.getInstance();
    s5 = await initS5();
  } catch (e) {
    logger.d("Failed to connect to an online session: $e");
  }
  msg = MsgCore(s5: s5, bskySession: session, bskyChatSession: chatSession);
  msg!.init();

  // Go go program!
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
        return OverlaySupport.global(
          child: MaterialApp(
            title: 'Vup Chat',
            theme: getLightTheme(),
            darkTheme: getDarkTheme(),
            themeMode: _themeMode,
            debugShowCheckedModeBanner: false,
            home: BasedSplashPage(
              rootPage: BasedSplitView(
                navigatorKey: vupSplitViewKey,
                leftWidget: InitRouter(
                  key: _leftKey,
                ),
                rightPlaceholder: const PlaceHolderPage(),
              ),
              appIcon: img.Image.asset(
                'static/icon.png',
                width: 150.h,
              ),
              appName: const Text(''),
            ),
          ),
        );
      },
    );
  }
}
