// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserItemDataDto _$UserItemDataDtoFromJson(Map<String, dynamic> json) =>
    _UserItemDataDto(
      playbackPositionTicks:
          (json['PlaybackPositionTicks'] as num?)?.toInt() ?? 0,
      played: json['Played'] as bool? ?? false,
      playedPercentage: (json['PlayedPercentage'] as num?)?.toDouble(),
      unplayedItemCount: (json['UnplayedItemCount'] as num?)?.toInt(),
    );

const _$UserItemDataDtoFieldMap = <String, String>{
  'playbackPositionTicks': 'PlaybackPositionTicks',
  'played': 'Played',
  'playedPercentage': 'PlayedPercentage',
  'unplayedItemCount': 'UnplayedItemCount',
};

Map<String, dynamic> _$UserItemDataDtoToJson(_UserItemDataDto instance) =>
    <String, dynamic>{
      'PlaybackPositionTicks': instance.playbackPositionTicks,
      'Played': instance.played,
      'PlayedPercentage': ?instance.playedPercentage,
      'UnplayedItemCount': ?instance.unplayedItemCount,
    };
