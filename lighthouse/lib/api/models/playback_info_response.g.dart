// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackInfoResponse _$PlaybackInfoResponseFromJson(
  Map<String, dynamic> json,
) => _PlaybackInfoResponse(
  mediaSources:
      (json['MediaSources'] as List<dynamic>?)
          ?.map((e) => MediaSourceInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  playSessionId: json['PlaySessionId'] as String?,
  errorCode: json['ErrorCode'] as String?,
);

const _$PlaybackInfoResponseFieldMap = <String, String>{
  'mediaSources': 'MediaSources',
  'playSessionId': 'PlaySessionId',
  'errorCode': 'ErrorCode',
};

Map<String, dynamic> _$PlaybackInfoResponseToJson(
  _PlaybackInfoResponse instance,
) => <String, dynamic>{
  'MediaSources': instance.mediaSources.map((e) => e.toJson()).toList(),
  'PlaySessionId': ?instance.playSessionId,
  'ErrorCode': ?instance.errorCode,
};
