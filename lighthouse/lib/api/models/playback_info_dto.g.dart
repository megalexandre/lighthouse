// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

const _$PlaybackInfoDtoFieldMap = <String, String>{
  'userId': 'UserId',
  'deviceProfile': 'DeviceProfile',
  'startTimeTicks': 'StartTimeTicks',
  'audioStreamIndex': 'AudioStreamIndex',
  'subtitleStreamIndex': 'SubtitleStreamIndex',
  'mediaSourceId': 'MediaSourceId',
  'maxStreamingBitrate': 'MaxStreamingBitrate',
  'autoOpenLiveStream': 'AutoOpenLiveStream',
};

Map<String, dynamic> _$PlaybackInfoDtoToJson(_PlaybackInfoDto instance) =>
    <String, dynamic>{
      'UserId': instance.userId,
      'DeviceProfile': instance.deviceProfile.toJson(),
      'StartTimeTicks': ?instance.startTimeTicks,
      'AudioStreamIndex': ?instance.audioStreamIndex,
      'SubtitleStreamIndex': ?instance.subtitleStreamIndex,
      'MediaSourceId': ?instance.mediaSourceId,
      'MaxStreamingBitrate': ?instance.maxStreamingBitrate,
      'AutoOpenLiveStream': instance.autoOpenLiveStream,
    };
