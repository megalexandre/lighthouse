// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackInfoDto _$PlaybackInfoDtoFromJson(Map<String, dynamic> json) =>
    _PlaybackInfoDto(
      userId: json['UserId'] as String,
      deviceProfile: DeviceProfile.fromJson(
        json['DeviceProfile'] as Map<String, dynamic>,
      ),
      startTimeTicks: (json['StartTimeTicks'] as num?)?.toInt(),
      audioStreamIndex: (json['AudioStreamIndex'] as num?)?.toInt(),
      subtitleStreamIndex: (json['SubtitleStreamIndex'] as num?)?.toInt(),
      mediaSourceId: json['MediaSourceId'] as String?,
      maxStreamingBitrate: (json['MaxStreamingBitrate'] as num?)?.toInt(),
      autoOpenLiveStream: json['AutoOpenLiveStream'] as bool? ?? true,
    );

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
