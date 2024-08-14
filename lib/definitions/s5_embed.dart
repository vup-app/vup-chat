import 'package:json_annotation/json_annotation.dart';

part 's5_embed.g.dart';

@JsonSerializable()
class S5Embed {
  final String? cid;
  final String caption;
  final String thumbhash;
  final String $type;

  S5Embed({
    required this.cid,
    required this.caption,
    required this.thumbhash,
    required this.$type,
  });

  // Factory constructor to create an S5Embed instance from JSON
  factory S5Embed.fromJson(Map<String, dynamic> json) =>
      _$S5EmbedFromJson(json);

  // Method to convert an S5Embed instance to JSON
  Map<String, dynamic> toJson() => _$S5EmbedToJson(this);
}
