import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget chatsSearchBar(TextEditingController textController,
    Function navToSettings, Function navToProfile) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(8.h),
      child: TextField(
        controller: textController,
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
          prefixIcon: (textController.text.isEmpty)
              ? const Icon(Icons.search)
              : InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    textController.clear();
                  },
                ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 0.h),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'Settings') {
                  navToSettings();
                } else if (value == 'Profile') {
                  navToProfile();
                }
              },
              icon: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                  ),
                ];
              },
            ),
          ),
          hintText: 'Search...',
        ),
      ),
    ),
  );
}
