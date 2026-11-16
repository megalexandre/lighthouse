// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_item_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateUserItemDataDto _$UpdateUserItemDataDtoFromJson(
  Map<String, dynamic> json,
) => _UpdateUserItemDataDto(
  playbackPositionTicks: (json['PlaybackPositionTicks'] as num?)?.toInt(),
  played: json['Played'] as bool?,
);

const _$UpdateUserItemDataDtoFieldMap = <String, String>{
  'playbackPositionTicks': 'PlaybackPositionTicks',
  'played': 'Played',
};

Map<String, dynamic> _$UpdateUserItemDataDtoToJson(
  _UpdateUserItemDataDto instance,
) => <String, dynamic>{
  'PlaybackPositionTicks': ?instance.playbackPositionTicks,
  'Played': ?instance.played,
};
