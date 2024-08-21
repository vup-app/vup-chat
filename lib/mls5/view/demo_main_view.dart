import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/main.dart';

import 'group_chat.dart';
import 'group_list.dart';

class MLS5DemoAppView extends StatelessWidget {
  const MLS5DemoAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text(
          'Vup Chat - Decentralized E2EE group chats with MLS and the S5 Network',
        )),
        body: StreamBuilder<void>(
            stream: mls5.mainWindowState.stream,
            builder: (context, snapshot) {
              return Row(
                children: [
                  SizedBox(
                    width: 100.w,
                    child: const GroupListView(),
                  ),
                  if (mls5.mainWindowState.groupId != null) ...[
                    const VerticalDivider(
                      width: 1,
                    ),
                    Expanded(
                      child: GroupChatView(
                        mls5.mainWindowState.groupId!,
                      ),
                    )
                  ]
                  /*  Center(
                  child: ElevatedButton(
                    onPressed: mls.test,
                    child: Text('Run'),
                  ),
                ), */
                ],
              );
            }),
      ),
    );
  }
}
