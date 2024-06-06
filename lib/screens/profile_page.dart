import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/log_out.dart';
import 'package:vup_chat/bsky/profile_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/login_page.dart';
import 'package:flutter/src/widgets/image.dart' as img;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Future<PersonalProfileInfo>? _profileInfoFuture;

  @override
  void initState() {
    super.initState();
    _profileInfoFuture = fetchProfile(false);
  }

  Future<void> _logOut() async {
    session = await tryLogOut();
    if (mounted && session == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Use a default title
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logOut,
          ),
        ],
      ),
      body: FutureBuilder<PersonalProfileInfo>(
        future: _profileInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profileInfo = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileInfo.banner != null)
                    img.Image.memory(
                      profileInfo.banner!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (profileInfo.avatar != null)
                          CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  MemoryImage(profileInfo.avatar!)),
                        const SizedBox(width: 16),
                        Text(
                          profileInfo.displayName ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      profileInfo.description ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Show a loading indicator while waiting
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
