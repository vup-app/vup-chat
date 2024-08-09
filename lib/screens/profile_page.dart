import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vup_chat/bsky/profile_actions.dart';
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:vup_chat/main.dart';
import 'package:vup_chat/widgets/restart_widget.dart';

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
    await msg.logOutBsky();
    if (mounted && msg.bskySession == null) {
      RestartWidget.restartApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder<PersonalProfileInfo>(
        future: _profileInfoFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildContent(snapshot),
          );
        },
      ),
    ));
  }

  Widget _buildContent(AsyncSnapshot<PersonalProfileInfo> snapshot) {
    if (!kIsWeb && snapshot.connectionState == ConnectionState.waiting) {
      return _buildShimmerPlaceholder();
    } else if (kIsWeb && snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasData) {
      if (snapshot.data != null) {
        final profileInfo = snapshot.data!;
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileInfo.banner != null && profileInfo.avatar != null)
                    Stack(
                      children: [
                        img.Image.memory(
                          profileInfo.banner!,
                          fit: BoxFit.cover,
                          height: 200.h,
                          width: double.infinity,
                        ),
                        Positioned(
                          top: 16.h,
                          right: 16.w,
                          child: IconButton(
                            icon: const Icon(Icons.logout,
                                color: Colors.white, size: 30),
                            onPressed: _logOut,
                            style: ButtonStyle(
                              shadowColor: WidgetStateProperty.all(
                                  Colors.black.withOpacity(0.5)),
                              elevation: WidgetStateProperty.all(5),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16.w,
                          top: 20.h,
                          child: CircleAvatar(
                            radius: 80.h,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 75.h,
                              backgroundImage: profileInfo.avatar != null
                                  ? MemoryImage(profileInfo.avatar!)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileInfo.displayName ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (profileInfo.description != null)
                                Text(
                                  profileInfo.description!,
                                  style: const TextStyle(
                                    fontSize: 14, // Smaller text size
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else if (snapshot.hasError) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show a loading indicator while waiting
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildShimmerPlaceholder() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 200.h,
                  width: double.infinity,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 24.h,
                              width: 200.w,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                              height: 10
                                  .h), // Add spacing for potential description
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 14.h,
                              width: double.infinity,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
