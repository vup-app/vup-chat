import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vup_chat/main.dart';

class DesktopModeSwitch extends StatefulWidget {
  const DesktopModeSwitch({super.key});

  @override
  DesktopModeSwitchState createState() => DesktopModeSwitchState();
}

class DesktopModeSwitchState extends State<DesktopModeSwitch> {
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchState(); // Load the saved state on initialization
  }

  Future<void> _loadSwitchState() async {
    final bool? switchValue = preferences.getBool("desktop_mode_switch");
    if (switchValue != null) {
      setState(() {
        _isSwitched = switchValue;
      });
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        preferences.setBool("desktop_mode_switch", false);
        setState(() {
          _isSwitched = false;
        });
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        preferences.setBool("desktop_mode_switch", true);
        setState(() {
          _isSwitched = true;
        });
      } else {
        preferences.setBool("desktop_mode_switch", true);
        setState(() {
          _isSwitched = true;
        });
      }
    }
  }

  Future<void> _saveSwitchState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("desktop_mode_switch", value);
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isSwitched,
      onChanged: (value) {
        setState(() {
          _isSwitched = value;
          _saveSwitchState(value); // Save the new state
        });
      },
    );
  }
}
