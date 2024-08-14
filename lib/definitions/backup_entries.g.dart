// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_entries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupEntry _$BackupEntryFromJson(Map<String, dynamic> json) => BackupEntry(
      dateTime: DateTime.parse(json['dateTime'] as String),
      dataCID: json['dataCID'] as String,
    );

Map<String, dynamic> _$BackupEntryToJson(BackupEntry instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime.toIso8601String(),
      'dataCID': instance.dataCID,
    };

BackupEntries _$BackupEntriesFromJson(Map<String, dynamic> json) =>
    BackupEntries(
      backupEntries: (json['backupEntries'] as List<dynamic>)
          .map((e) => BackupEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BackupEntriesToJson(BackupEntries instance) =>
    <String, dynamic>{
      'backupEntries': instance.backupEntries,
    };
