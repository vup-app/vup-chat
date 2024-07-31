import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

CircleAvatar getCircleAvatar(
  Uint8List? avatarBytes,
  String? avatarUrl,
) {
  late CircleAvatar circleAvatar;
  if (kIsWeb) {
    if (avatarUrl != null) {
      circleAvatar =
          CircleAvatar(backgroundImage: Image.network(avatarUrl).image);
    } else {
      circleAvatar = const CircleAvatar();
    }
  } else {
    if (avatarBytes != null) {
      circleAvatar = CircleAvatar(
        backgroundImage: Image.memory(avatarBytes).image,
      );
    } else {
      circleAvatar = const CircleAvatar();
    }
  }
  return circleAvatar;
}
