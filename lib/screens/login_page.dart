import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/try_log_in.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/home_page.dart';

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
    if (session != null && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }

  Future<void> _login() async {
    await storage.write(key: 'user', value: userController.text);
    await storage.write(key: 'password', value: passwordController.text);
    session = await tryLogIn(userController.text, passwordController.text);
    if (mounted && session != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              controller: userController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              controller: passwordController,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
