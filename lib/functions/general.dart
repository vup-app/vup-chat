import 'package:vup_chat/main.dart';

bool isDesktop() {
  bool? isDesky = preferences.getBool("desktop_mode_switch");
  return isDesky ?? true;
}
