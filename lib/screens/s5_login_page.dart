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
import 'package:vup_chat/widgets/smart_width.dart';

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
  bool _currentlyLoggingIn = false;
  late Animation<Offset> _offsetAnimation;
  late AnimationController _controller;
  String _seed = "loading...";
  int _toggleState = 0;
  bool _advancedIsExpanded = false;

  @override
  void initState() {
    super.initState();
    _getSeed();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  void _getSeed() async {
    // So if S5 is in a weird broken state and fails to initialze because of old junk
    // this function will clear out the previous failed login and then reinit
    // once it does that it can get the seed
    if (msg.s5 != null) {
      setState(() {
        _seed = msg.s5!.generateSeedPhrase();
      });
    } else {
      await logOutS5NoRestart();
      await initS5();
      if (msg.s5 != null) {
        setState(() {
          _seed = msg.s5!.generateSeedPhrase();
        });
      }
    }
  }

  void _login(BuildContext context) async {
    // flow for on login
    // check if seed is valid, and if it isn't fail
    if (context.mounted) {
      setState(() {
        _currentlyLoggingIn = true;
      });
      late String seed;
      late String node;
      if (_toggleState == 0) {
        seed = _seedController.text;
        node = _nodeController.text;
      } else {
        seed = _seed;
        node = _nodeController.text;
      }
      try {
        await msg.logInS5(seed, node);
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _currentlyLoggingIn = false;
          _isLoginFailed = true;
        });
        SnackBar snackBar = SnackBar(content: Text("$e"));
        if (vupSplitViewKey.currentContext != null) {
          ScaffoldMessenger.of(vupSplitViewKey.currentContext!)
              .showSnackBar(snackBar);
        }
        _controller.forward().then((_) => _controller.reverse());
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isLoginFailed = false;
          _currentlyLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SmartWidth(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80.h,
              ),

              Text(
                "S5 Login",
                style: TextStyle(
                  fontSize: 25.h,
                  decoration: TextDecoration.none,
                ),
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
                        "Logging into S5 requires you create and remember a 15 word cryptographic seed. This seed is separate from your Bluesky account and is persisted separately. Logging into S5 will allow you to use advanced features like: sending media (photos, videos, voice memos), typing indicators, and E2EE. It is NOT recoverable if you lose it. Learn more here: https://docs.sfive.net"),
              ),
              SizedBox(
                height: 5.h,
              ),
              Column(
                children: [
                  AnimatedToggleSwitch<int>.size(
                    current: min(_toggleState, 1),
                    style: ToggleStyle(
                      indicatorColor: Theme.of(context).primaryColor,
                      borderColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1.5),
                        ),
                      ],
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
                          child: Text(
                        text,
                      ));
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
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: _isLoginFailed
                                ? Colors.red
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      child: (_currentlyLoggingIn)
                          ? const CircularProgressIndicator()
                          : Text(
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
                      onPressed: () {
                        preferences.setBool("disable-s5", true);
                        vupSplitViewKey.currentState?.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Theme.of(context).cardColor),
                        ),
                      ),
                      child: Text(
                        "No Thanks",
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
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
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
                            labelText: 'S5 Node',
                            hintText: "https://s5.ninja"),
                      ),
                    ),
                ],
              ),

              SizedBox(
                height: 50.h,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
