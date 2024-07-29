import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ChatPlaceholderList extends StatelessWidget {
  const ChatPlaceholderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        // The search bar at the top
        Center(
          child: Padding(
            padding: EdgeInsets.all(8.h),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.h),
                  borderSide: BorderSide(
                    width: 1.h,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.h),
                  borderSide: BorderSide(
                    width: 1.h,
                  ),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 4.h),
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                hintText: 'Search...',
              ),
            ),
          ),
        ),
        // then the placeholder chats below that
        ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ChatPlaceholder(
              position: index,
            );
          },
        ),
      ],
    ));
  }
}

class ChatPlaceholder extends StatelessWidget {
  final int position;

  const ChatPlaceholder({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    double opacity = 1;
    if (position == 0) {
    } else if (position == 1) {
      opacity = .5;
    } else if (position == 2) {
      opacity = .2;
    } else {
      opacity = 0;
    }
    return Opacity(
        opacity: opacity,
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).canvasColor,
          highlightColor: Theme.of(context).highlightColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 5.0),
                      Container(
                        width: 150.0,
                        height: 15.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
