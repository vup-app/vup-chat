import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';

bool isDesktop() {
  bool? isDesky = preferences.getBool("desktop_mode_switch");
  return isDesky ?? true;
}

CircleAvatar avatarFromMembersJSON(List<dynamic> membersJson) {
  // Create CircleAvatar based on the avatar URL in the last element
  final CircleAvatar avatar =
      membersJson.isNotEmpty && membersJson.last['avatar'] != null
          ? CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(membersJson.last['avatar']),
            )
          : const CircleAvatar(child: Icon(Icons.person));

  return avatar;
}

String handleFromMembersJSON(List<dynamic> membersJson, bool notEmpty) {
  return notEmpty ? membersJson.last["displayName"] : "null";
}
