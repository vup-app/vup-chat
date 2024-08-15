import 'dart:async';

import 'package:based_splash_page/based_splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:vup_chat/messenger/core.dart';
import 'package:vup_chat/mls5/mls5.dart';
import 'package:vup_chat/theme.dart';
import 'package:vup_chat/widgets/init_router.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:vup_chat/widgets/restart_widget.dart';

import 'package:vup_chat/src/rust/api/simple.dart';
import 'package:vup_chat/src/rust/frb_generated.dart';

// TODO: Move these to providers and stop mucking about with
// global state
const FlutterSecureStorage secureStorage = FlutterSecureStorage();
final Logger logger = Logger();
late SharedPreferences preferences;
final vupSplitViewKey = GlobalKey<NavigatorState>();
final leftKey = GlobalKey();
MsgCore msg = MsgCore();
String? did;
bool inBackground = false;
String currentChatID = "";

final mls5 = MLS5();

void main() async {
  // Init preferences here because it's really fast
  WidgetsFlutterBinding.ensureInitialized();
  preferences = await SharedPreferences.getInstance();
  await RustLib.init();
  try {
    await msg.msgInitS5(); // Also this doesn't take long and it's better here
    await mls5.init();
  } catch (e) {
    logger.e("Failed to init S5: $e");
  }

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
  late StreamSubscription<FGBGType> subscription;

  // void _toggleTheme() {
  //   setState(() {
  //     _themeMode =
  //         _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  //   });
  // }

  @override
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      subscription = FGBGEvents.stream.listen((event) {
        switch (event) {
          case FGBGType.foreground:
            inBackground = false;
          case FGBGType.background:
            inBackground = true;
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return OverlaySupport.global(
          child: RestartWidget(
            child: MaterialApp(
              title: 'Vup Chat',
              theme: getLightTheme(),
              darkTheme: getDarkTheme(),
              themeMode: _themeMode,
              debugShowCheckedModeBanner: false,
              home: BasedSplashPage(
                rootPage: const InitRouter(),
                appIcon: img.Image.asset(
                  'static/icon.png',
                  width: 150.h,
                ),
                appName: const Text(''),
              ),
            ),
          ),
        );
      },
    );
  }
}
