import 'package:based_split_view/based_split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vup_chat/constants.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/chat_list_page.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:vup_chat/screens/place_holder_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isLoginFailed = false;

  @override
  void initState() {
    super.initState();
    _checkSession();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0.0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  Future<void> _checkSession() async {
    // Replace this logic with your actual session check
    if (msg.bskySession != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatListPage()),
      );
    }
  }

  Future<void> _login() async {
    await secureStorage.write(key: 'user', value: userController.text);
    await secureStorage.write(key: 'password', value: passwordController.text);
    await msg.attemptLogin(userController.text, passwordController.text);
    await msg.requestPerms();
    if (mounted && msg.bskySession != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BasedSplitView(
              navigatorKey: vupSplitViewKey,
              leftWidget: ChatListPage(
                key: leftKey,
              ),
              rightPlaceholder: const PlaceHolderPage(),
            ),
          ));
    } else {
      setState(() {
        _isLoginFailed = true;
      });
      _controller.forward().then((_) => _controller.reverse());
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoginFailed = false;
      });
    }
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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

                img.Image.asset(
                  'static/icon.png',
                  width: 150.h,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Vup Chat",
                  style: TextStyle(
                      fontSize: 25.h,
                      decoration: TextDecoration.none,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const Spacer(),
                Container(
                    height: 40, // This should match the height of the SizedBox
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white, // Change outline color
                                  width: 2.0, // Change outline thickness
                                ),
                              ),
                              width: 30, // Adjust size
                              height: 30,
                              child: Tooltip(
                                message:
                                    "What's this? Click question mark to learn about app passwords.",
                                child: InkWell(
                                  onTap: () => launchUrl(Uri.parse(
                                      "https://blueskyfeeds.com/en/faq-app-password")),
                                  child: const Center(
                                    child: Icon(Icons.question_mark,
                                        size: 25), // Adjust icon size if needed
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    autofillHints: const [AutofillHints.username],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'foo@bar.com',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.h,
                        ),
                      ),
                    ),
                    controller: userController,
                  ),
                ),
                SizedBox(height: 5.h), // Vertical spacing
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                      textAlign: TextAlign.center,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'App Password',
                        hintText: 'ndsl-kdiw-ndba-nadk',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.h,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ),
                      controller: passwordController,
                      obscureText: obscureText,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) {
                        _login();
                      }),
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
                Linkify(
                  onOpen: (link) async {
                    if (!await launchUrl(Uri.parse(link.url))) {
                      throw Exception('Could not launch ${link.url}');
                    }
                  },
                  text: "Development funded by https://sia.tech",
                  style: const TextStyle(color: Colors.grey),
                  linkStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                TextButton(
                  onPressed: () => launchUrl(
                      Uri.parse("https://github.com/vup-app/vup-chat/")),
                  child: const Text(
                    version,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
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
