import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vup_chat/constants.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/widgets/desktop_mode_switch.dart';
import 'package:vup_chat/widgets/s5_status_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool globalNotifications = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      globalNotifications = preferences.getBool("notif-global") ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // enable global notifications switch
          Row(
            children: [
              const SizedBox(height: 20),
              const Text('Notifications: '),
              Switch(
                value: globalNotifications,
                onChanged: (val) {
                  setState(() {
                    globalNotifications = val;
                  });
                  preferences.setBool("notif-global", val);
                },
              )
            ],
          ),
          // S5 Login space
          const S5StatusWidget(),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    // I know multiple DB opens is bad, but it's read only so it's fine
                    builder: (context) => DriftDbViewer(msg!.getDB())));
              },
              child: const Text("View DB")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  version,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Add URL launch functionality if needed
                    },
                    child: Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url))) {
                          throw Exception('Could not launch ${link.url}');
                        }
                      },
                      text: "Source code: https://github.com/vup-app/vup-chat/",
                      style: const TextStyle(color: Colors.grey),
                      linkStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
