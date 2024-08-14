import 'dart:convert';
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

part 'backup_entries.g.dart';

@JsonSerializable()
class BackupEntry {
  DateTime dateTime;
  String dataCID; // CID

  BackupEntry({
    required this.dateTime,
    required this.dataCID,
  });

  // Custom fromJson for Uint8List
  static Uint8List _dataFromJson(String data) => base64Decode(data);

  // Custom toJson for Uint8List
  static String _dataToJson(Uint8List data) => base64Encode(data);

  // Factory constructor to create a BackupEntry instance from JSON
  factory BackupEntry.fromJson(Map<String, dynamic> json) =>
      _$BackupEntryFromJson(json);

  // Method to convert a BackupEntry instance to JSON
  Map<String, dynamic> toJson() => _$BackupEntryToJson(this);

  // Convert to a Uint8List by encoding to JSON first
  Uint8List toUint8List() {
    final jsonStr = jsonEncode(toJson());
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  // Convert from Uint8List to BackupEntry
  static BackupEntry fromUint8List(Uint8List uint8list) {
    final jsonStr = utf8.decode(uint8list);
    return BackupEntry.fromJson(jsonDecode(jsonStr));
  }
}

@JsonSerializable()
class BackupEntries {
  List<BackupEntry> backupEntries;

  BackupEntries({required this.backupEntries});

  // Factory constructor to create BackupEntries instance from JSON
  factory BackupEntries.fromJson(Map<String, dynamic> json) =>
      _$BackupEntriesFromJson(json);

  // Method to convert a BackupEntries instance to JSON
  Map<String, dynamic> toJson() => _$BackupEntriesToJson(this);

  // Method to add a new BackupEntry and sort by most recent date
  void addEntry(BackupEntry entry) {
    backupEntries.add(entry);
    backupEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Convert the list to Uint8List by encoding it to JSON first
  Uint8List toUint8List() {
    final jsonStr = jsonEncode(toJson());
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  // Convert from Uint8List to BackupEntries
  static BackupEntries fromUint8List(Uint8List uint8list) {
    final jsonStr = utf8.decode(uint8list);
    return BackupEntries.fromJson(jsonDecode(jsonStr));
  }
}
