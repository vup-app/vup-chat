// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_entries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyEntry _$KeyEntryFromJson(Map<String, dynamic> json) => KeyEntry(
      kp: KeyEntry._uint8ListFromJson(json['kp'] as List<int>),
      pk: KeyEntry._uint8ListFromJson(json['pk'] as List<int>),
    );

Map<String, dynamic> _$KeyEntryToJson(KeyEntry instance) => <String, dynamic>{
      'kp': KeyEntry._uint8ListToJson(instance.kp),
      'pk': KeyEntry._uint8ListToJson(instance.pk),
    };
