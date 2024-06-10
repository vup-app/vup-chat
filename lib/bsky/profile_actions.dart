import 'dart:convert';
import 'dart:typed_data';

import 'package:bluesky/bluesky.dart';
import 'package:vup_chat/main.dart';

class PersonalProfileInfo {
  String? displayName;
  String? description;
  Uint8List? avatar;
  Uint8List? banner;

  PersonalProfileInfo(
      this.displayName, this.description, this.avatar, this.banner);
}

Future<PersonalProfileInfo> fetchProfile(bool update) async {
  // TODO: Caching personal profile for offline
  // TODO: Pull down refresh on personal profile
  final response = await session!.actor.getProfileRecord();

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
  return PersonalProfileInfo(
      displayName, description, avatarBytes, bannerBytes);
}
