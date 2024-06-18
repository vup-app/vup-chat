import 'package:flutter/material.dart';
import 'package:vup_chat/widgets/app_bar_back.dart';
import 'package:vup_chat/widgets/desktop_mode_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: backButton(context),
      ),
      body: const Row(
        children: [
          SizedBox(height: 20),
          Text('Desktop Mode:'),
          DesktopModeSwitch(),
        ],
      ),
    );
  }
}
