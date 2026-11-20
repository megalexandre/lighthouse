// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$PlaybackProgressInfoFieldMap = <String, String>{
  'itemId': 'ItemId',
  'mediaSourceId': 'MediaSourceId',
  'playSessionId': 'PlaySessionId',
  'positionTicks': 'PositionTicks',
  'isPaused': 'IsPaused',
  'isMuted': 'IsMuted',
  'canSeek': 'CanSeek',
  'playMethod': 'PlayMethod',
  'audioStreamIndex': 'AudioStreamIndex',
  'subtitleStreamIndex': 'SubtitleStreamIndex',
  'volumeLevel': 'VolumeLevel',
};

Map<String, dynamic> _$PlaybackProgressInfoToJson(
  _PlaybackProgressInfo instance,
) => <String, dynamic>{
  'ItemId': instance.itemId,
  'MediaSourceId': instance.mediaSourceId,
  'PlaySessionId': ?instance.playSessionId,
  'PositionTicks': instance.positionTicks,
  'IsPaused': instance.isPaused,
  'IsMuted': instance.isMuted,
  'CanSeek': instance.canSeek,
  'PlayMethod': _$PlayMethodEnumMap[instance.playMethod]!,
  'AudioStreamIndex': ?instance.audioStreamIndex,
  'SubtitleStreamIndex': ?instance.subtitleStreamIndex,
  'VolumeLevel': ?instance.volumeLevel,
};

const _$PlayMethodEnumMap = {
  PlayMethod.directPlay: 'DirectPlay',
  PlayMethod.directStream: 'DirectStream',
  PlayMethod.transcode: 'Transcode',
};

const _$PlaybackStopInfoFieldMap = <String, String>{
  'itemId': 'ItemId',
  'mediaSourceId': 'MediaSourceId',
  'playSessionId': 'PlaySessionId',
  'positionTicks': 'PositionTicks',
  'failed': 'Failed',
};

Map<String, dynamic> _$PlaybackStopInfoToJson(_PlaybackStopInfo instance) =>
    <String, dynamic>{
      'ItemId': instance.itemId,
      'MediaSourceId': instance.mediaSourceId,
      'PlaySessionId': ?instance.playSessionId,
      'PositionTicks': instance.positionTicks,
      'Failed': instance.failed,
    };
