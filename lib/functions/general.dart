import 'package:flutter/material.dart';
import 'package:vup_chat/main.dart';

bool isDesktop() {
  bool? isDesky = preferences.getBool("desktop_mode_switch");
  return isDesky ?? true;
}

CircleAvatar avatarFromMembersJSON(List<dynamic> membersJson) {
  final CircleAvatar avatar = membersJson.isNotEmpty &&
          membersJson.last['avatar'] != null
      ? CircleAvatar(backgroundImage: NetworkImage(membersJson.last['avatar']))
      : const CircleAvatar(child: Icon(Icons.person));
  return avatar;
}

String handleFromMembersJSON(List<dynamic> membersJson, bool notEmpty) {
  return notEmpty ? membersJson.last["displayName"] : "null";
}
