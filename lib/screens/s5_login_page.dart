import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vup_chat/functions/s5.dart';
import 'package:vup_chat/main.dart';

class S5LoginPage extends StatefulWidget {
  const S5LoginPage({super.key});

  @override
  S5LoginPageState createState() => S5LoginPageState();
}

class S5LoginPageState extends State<S5LoginPage>
    with SingleTickerProviderStateMixin {
  final _seedController = TextEditingController();
  final _nodeController = TextEditingController();
  bool _isLoginFailed = false;
  late Animation<Offset> _offsetAnimation;
  late AnimationController _controller;
  String _seed = "";
  int _toggleState = 0;
  bool _advancedIsExpanded = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _seed = s5.generateSeedPhrase();
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  void _login() async {
    // flow for on login
    // check if seed is valid, and if it isn't fail
    if (context.mounted) {
      if (_toggleState == 0) {
        try {
          await logInS5(_seedController.text, _nodeController.text);
          Navigator.pop(context);
        } catch (e) {
          setState(() {
            _isLoginFailed = true;
          });
          SnackBar snackBar = SnackBar(content: Text("$e"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          _controller.forward().then((_) => _controller.reverse());
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _isLoginFailed = false;
          });
        }
        // flow for on register
      } else {
        await logInS5(_seed, _nodeController.text);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.all(5.w), // Adjust margin as needed
          constraints: const BoxConstraints(maxWidth: 600),
          child: SizedBox(
            width: 300.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                SizedBox(
                  height: 80.h,
                ),

                Text(
                  "S5 Login",
                  style: TextStyle(color: Colors.white, fontSize: 25.h),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url))) {
                          throw Exception('Could not launch ${link.url}');
                        }
                      },
                      style: const TextStyle(fontSize: 20),
                      text:
                          "Logging into S5 requires you create and remember a 15 word cryptographic seed. This seed is separate from your Bluesky account and is persisted separately. Logging into S5 will allow you to used advanced features like: sending media (photos, videos, voice memos), typing indicators, and E2EE. It is NOT recoverable if you lose it. Learn more here: https://docs.sfive.net"),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Column(
                  children: [
                    AnimatedToggleSwitch<int>.size(
                      current: min(_toggleState, 1),
                      style: ToggleStyle(
                        backgroundColor: Theme.of(context).cardColor,
                        indicatorColor: Theme.of(context).primaryColor,
                        borderColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        indicatorBorderRadius: BorderRadius.zero,
                      ),
                      values: const [0, 1],
                      iconOpacity: 1.0,
                      selectedIconScale: 1.0,
                      indicatorSize: const Size.fromWidth(100),
                      iconAnimationType: AnimationType.onHover,
                      styleAnimationType: AnimationType.onHover,
                      spacing: 2.0,
                      customSeparatorBuilder: (context, local, global) {
                        final opacity =
                            ((global.position - local.position).abs() - 0.5)
                                .clamp(0.0, 1.0);
                        return VerticalDivider(
                            indent: 10.0,
                            endIndent: 10.0,
                            color: Colors.white38.withOpacity(opacity));
                      },
                      customIconBuilder: (context, local, global) {
                        final text = const ['Log In', 'Register'][local.index];
                        return Center(
                            child: Text(text,
                                style: const TextStyle(color: Colors.white)));
                      },
                      borderWidth: 0.0,
                      onChanged: (i) => setState(() => _toggleState = i),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _toggleState == 0
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  labelText: 'Seed',
                                  hintText: 'shmee shooo shopp ...',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                controller: _seedController,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _seed,
                                        overflow: TextOverflow.fade,
                                        softWrap: true,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy,
                                          color: Colors.white),
                                      onPressed: () {
                                        Clipboard.setData(
                                                ClipboardData(text: _seed))
                                            .then((result) {
                                          const snackBar = SnackBar(
                                              content:
                                                  Text('Copied to clipboard!'));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),

                SizedBox(height: 5.h), // Vertical spacing
                SlideTransition(
                  position: _offsetAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: _isLoginFailed
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color: _isLoginFailed
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Container(
                    width: double.infinity,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side:
                                BorderSide(color: Theme.of(context).cardColor),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ))),
                SizedBox(
                  height: 5.h,
                ),
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _advancedIsExpanded = !_advancedIsExpanded;
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Advanced',
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor),
                          ),
                          Icon(_advancedIsExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    if (_advancedIsExpanded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _nodeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'S5 Default Node',
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(
                  height: 50.h,
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
