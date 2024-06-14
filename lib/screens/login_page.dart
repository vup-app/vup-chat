import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/constants.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/home_page.dart';
import 'package:flutter/src/widgets/image.dart' as img;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  Bluesky? session;
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
    if (session != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _login() async {
    await storage.write(key: 'user', value: userController.text);
    await storage.write(key: 'password', value: passwordController.text);
    session = await tryLogIn(userController.text, passwordController.text);
    if (mounted && session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _isLoginFailed = true;
      });
      _controller.forward().then((_) => _controller.reverse());
      await Future.delayed(const Duration(seconds: 2));
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
                img.Image.asset(
                  'static/icon.png',
                  width: 150.h,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  "Vup Chat",
                  style: TextStyle(color: Colors.white, fontSize: 25.h),
                ),
                SizedBox(
                  height: 200.h,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkCardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'foo@bar.com',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: userController,
                  ),
                ),
                SizedBox(height: 5.h), // Vertical spacing
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkCardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'App Password',
                        hintText: 'ndsl-kdiw-ndba-nadk',
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
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
                      color: _isLoginFailed ? Colors.red : defaultAccentColor,
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
                                  : defaultAccentColor,
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
                  linkStyle: const TextStyle(color: defaultAccentColor),
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
