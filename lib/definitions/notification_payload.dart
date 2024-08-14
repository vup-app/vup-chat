import 'package:json_annotation/json_annotation.dart';

part 'notification_payload.g.dart';

@JsonSerializable()
class NotificationPayload {
  final String? did;
  final String chatID;

  NotificationPayload({
    required this.did,
    required this.chatID,
  });

  // Factory constructor to create an S5Embed instance from JSON
  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  // Method to convert an S5Embed instance to JSON
  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);
}
