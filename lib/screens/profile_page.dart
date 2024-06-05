import 'dart:io';
import 'dart:typed_data';

import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/log_out.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/screens/login_page.dart';
import 'package:atproto_core/atproto_core.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? displayName;
  String? description;
  Blob? avatarUrl;
  Blob? bannerUrl;
  Uint8List? avatarBytes;
  Uint8List? bannerBytes;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (session == null) {
      _logOut();
    }
    final response = await session!.actor.getProfileRecord();
    setState(() {
      displayName = response.data.displayName;
      description = response.data.description;
      avatarUrl = response.data.avatar;
      bannerUrl = response.data.banner;
    });
    if (avatarUrl != null) {
      // avatarBytes = await _fetchBlobBytes(avatarUrl!);
    }
    if (bannerUrl != null) {
      // bannerBytes = await _fetchBlobBytes(bannerUrl!);
    }
    setState(() {});
  }

  // Future<Uint8List> _fetchBlobBytes(Blob blob) async {
  //   // Assuming blob contains a URL to the image, you need to fetch the bytes from the URL.
  //   final response = await HttpClient()
  //       .getUrl(Uri.parse(blob.url))
  //       .then((req) => req.close());
  //   return response.fold<Uint8List>(
  //       Uint8List(0), (previous, element) => previous + element);
  // }

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
        title: Text(displayName ?? 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logOut,
          ),
        ],
      ),
      body: displayName == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bannerBytes != null)
                    // Image.memory(
                    //   bannerBytes!,
                    //   fit: BoxFit.cover,
                    //   width: double.infinity,
                    //   height: 200,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (avatarBytes != null)
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: MemoryImage(avatarBytes!),
                            ),
                          const SizedBox(width: 16),
                          Text(
                            displayName!,
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
                      description ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
