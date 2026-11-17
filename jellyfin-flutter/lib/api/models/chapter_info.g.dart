// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChapterInfo _$ChapterInfoFromJson(Map<String, dynamic> json) => _ChapterInfo(
  startPositionTicks: (json['StartPositionTicks'] as num?)?.toInt() ?? 0,
  name: json['Name'] as String?,
);

const _$ChapterInfoFieldMap = <String, String>{
  'startPositionTicks': 'StartPositionTicks',
  'name': 'Name',
};

Map<String, dynamic> _$ChapterInfoToJson(_ChapterInfo instance) =>
    <String, dynamic>{
      'StartPositionTicks': instance.startPositionTicks,
      'Name': ?instance.name,
    };
