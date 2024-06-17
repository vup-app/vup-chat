import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
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
      body: FutureBuilder<PersonalProfileInfo>(
        future: _profileInfoFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildContent(snapshot),
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<PersonalProfileInfo> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildShimmerPlaceholder();
    } else if (snapshot.hasData) {
      final profileInfo = snapshot.data!;
      return Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profileInfo.banner != null)
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
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
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
                period: const Duration(milliseconds: 500),
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
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      period: const Duration(milliseconds: 500),
                      child: CircleAvatar(
                        radius: 40.w,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            period: const Duration(milliseconds: 500),
                            child: Container(
                              width: 150.w,
                              height: 24.h,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            period: const Duration(milliseconds: 500),
                            child: Container(
                              width: 200.w,
                              height: 14.h,
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
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 500),
            child: Container(
              width: 30.w,
              height: 30.h,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
