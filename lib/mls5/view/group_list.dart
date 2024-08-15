import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lib5/util.dart';
import 'package:flutter/services.dart';
import 'package:vup_chat/main.dart';

class GroupListView extends StatefulWidget {
  const GroupListView({super.key});

  @override
  State<GroupListView> createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final group in mls5.groupsBox.values)
          ListTile(
            onTap: () {
              mls5.mainWindowState.groupId = group['id'];
              mls5.mainWindowState.update();
            },
            onLongPress: () async {
              final res = await showTextInputDialog(
                context: context,
                textFields: [
                  DialogTextField(hintText: 'Edit Group Name (local)'),
                ],
              );
              if (res == null) return;
              mls5.group(group['id']).rename(res.first);
            },
            title: Text(group['name']),
            subtitle: Text(group['id']),
            enabled: mls5.groups.isNotEmpty,
            selected: mls5.mainWindowState.groupId == group['id'],
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final res = await showTextInputDialog(
                    context: context,
                    textFields: [
                      DialogTextField(hintText: 'mls5-group-invite:')
                    ],
                  );
                  if (res == null) return;
                  final String welcome = res.first;
                  if (!welcome.startsWith('mls5-group-invite:')) throw 'TODO1';

                  final groupId = await mls5.acceptInviteAndJoinGroup(
                    base64UrlNoPaddingDecode(
                      welcome.substring(18),
                    ),
                  );
                  mls5.mainWindowState.groupId = groupId;
                  mls5.mainWindowState.update();
                },
                child: Text(
                  'Join Group',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  await mls5.createNewGroup();
                  setState(() {});
                },
                child: Text(
                  'Create Group',
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final kp = await mls5.createKeyPackage();

                  Clipboard.setData(
                    ClipboardData(
                      text: 'mls5-key-package:${base64UrlNoPaddingEncode(kp)}',
                    ),
                  );
                },
                child: Text(
                  'Copy KeyPackage',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
