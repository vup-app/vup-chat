import 'dart:convert';
import 'dart:typed_data';

import 'package:bluesky/bluesky.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vup_chat/main.dart';

class PersonalProfileInfo {
  String? displayName;
  String? description;
  Uint8List? avatar;
  Uint8List? banner;

  PersonalProfileInfo(
      this.displayName, this.description, this.avatar, this.banner);

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'description': description,
      'avatar': avatar != null ? base64Encode(avatar!) : null,
      'banner': banner != null ? base64Encode(banner!) : null,
    };
  }

  static PersonalProfileInfo fromJson(Map<String, dynamic> json) {
    return PersonalProfileInfo(
      json['displayName'] as String?,
      json['description'] as String?,
      json['avatar'] != null ? base64Decode(json['avatar']) : null,
      json['banner'] != null ? base64Decode(json['banner']) : null,
    );
  }
}

Future<PersonalProfileInfo> fetchProfile(bool update) async {
  final prefs = await SharedPreferences.getInstance();
  final cachedProfile = prefs.getString('cached_profile');

  if (cachedProfile != null && cachedProfile.isNotEmpty && !update) {
    return PersonalProfileInfo.fromJson(jsonDecode(cachedProfile));
  } else {
    final XRPCResponse<ProfileRecord> response =
        await session!.actor.getProfileRecord();

    String? displayName = response.data.displayName;
    String? description = response.data.description;
    Blob? avatarBlob = response.data.avatar;
    Blob? bannerBlob = response.data.banner;

    Uint8List? avatarBytes;
    Uint8List? bannerBytes;

    if (avatarBlob != null) {
      String cid = BlobRef.fromJson(avatarBlob.toJson()['ref']).link;
      if (did != null) {
        avatarBytes = (await session!.sync.getBlob(cid: cid, did: did!)).data;
      }
    }

    if (bannerBlob != null) {
      String cid = BlobRef.fromJson(bannerBlob.toJson()['ref']).link;
      if (did != null) {
        bannerBytes = (await session!.sync.getBlob(cid: cid, did: did!)).data;
      }
    }

    final profile =
        PersonalProfileInfo(displayName, description, avatarBytes, bannerBytes);

    await prefs.setString('cached_profile', jsonEncode(profile.toJson()));

    return profile;
  }
}

Future<void> followUser(String did) async {
  await session!.graph.follow(did: did);
}
