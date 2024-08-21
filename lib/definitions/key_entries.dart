import 'dart:convert';
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

part 'key_entries.g.dart';

@JsonSerializable()
class KeyEntry {
  @JsonKey(fromJson: _uint8ListFromJson, toJson: _uint8ListToJson)
  final Uint8List kp;

  @JsonKey(fromJson: _uint8ListFromJson, toJson: _uint8ListToJson)
  final Uint8List pk;

  KeyEntry({
    required this.kp,
    required this.pk,
  });

  // Factory constructor to create a KeyEntry instance from JSON
  factory KeyEntry.fromJson(Map<String, dynamic> json) =>
      _$KeyEntryFromJson(json);

  // Method to convert a KeyEntry instance to JSON
  Map<String, dynamic> toJson() => _$KeyEntryToJson(this);

  // Custom conversion methods for Uint8List
  static Uint8List _uint8ListFromJson(List<int> json) =>
      Uint8List.fromList(json);

  static List<int> _uint8ListToJson(Uint8List value) => value.toList();

  // Converts KeyEntry to a string representation
  @override
  String toString() {
    return jsonEncode({
      'kp': base64Encode(kp),
      'pk': base64Encode(pk),
    });
  }

  // Creates a KeyEntry instance from a string representation
  static KeyEntry fromString(String str) {
    Map<String, dynamic> json = jsonDecode(str);
    return KeyEntry(
      kp: base64Decode(json['kp']),
      pk: base64Decode(json['pk']),
    );
  }
}
