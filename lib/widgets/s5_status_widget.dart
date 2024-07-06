import 'package:flutter/material.dart';
import 'package:vup_chat/functions/s5.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/s5_login_page.dart';

class S5StatusWidget extends StatefulWidget {
  const S5StatusWidget({super.key});

  @override
  State<S5StatusWidget> createState() => _S5StatusWidgetState();
}

class _S5StatusWidgetState extends State<S5StatusWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (s5!.hasIdentity) {
      return Row(
        children: [
          const Text("S5 Status: "),
          const Icon(Icons.check),
          ElevatedButton(
            onPressed: () {
              logOutS5();
            },
            child: const Row(
              children: [Text("Log Out"), Icon(Icons.login)],
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          const Text("S5 Status: "),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const S5LoginPage())).then((_) => setState(
                  () {})); // this rebuilds to make sure it shows S5 logged in
            },
            child: const Row(
              children: [Text("Log In"), Icon(Icons.login)],
            ),
          )
        ],
      );
    }
  }
}
