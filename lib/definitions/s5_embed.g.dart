// GENERATED CODE - DO NOT MODIFY BY HAND

part of 's5_embed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

S5Embed _$S5EmbedFromJson(Map<String, dynamic> json) => S5Embed(
      cid: json['cid'] as String?,
      caption: json['caption'] as String,
      thumbhash: json['thumbhash'] as String,
      $type: json[r'$type'] as String,
    );

Map<String, dynamic> _$S5EmbedToJson(S5Embed instance) => <String, dynamic>{
      'cid': instance.cid,
      'caption': instance.caption,
      'thumbhash': instance.thumbhash,
      r'$type': instance.$type,
    };
