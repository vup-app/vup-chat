import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  Bluesky? session;

  @override
  void initState() {
    super.initState();
    _checkSession();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 360.w, // Fixed width for your UI
          height: 800.h, // Fixed height for your UI
          margin: EdgeInsets.all(5.w), // Adjust margin as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              img.Image.asset(
                'static/icon.png',
                width: 150.w,
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Vup Chat",
                style: TextStyle(color: Colors.white, fontSize: 25.w),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkCardColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
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
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),
              ),
              SizedBox(height: 5.h), // Vertical spacing
              Container(
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  color: defaultAccentColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(
                        color: defaultAccentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
