// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_source_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaSourceInfo _$MediaSourceInfoFromJson(Map<String, dynamic> json) =>
    _MediaSourceInfo(
      id: json['Id'] as String,
      container: json['Container'] as String?,
      runTimeTicks: (json['RunTimeTicks'] as num?)?.toInt(),
      supportsDirectPlay: json['SupportsDirectPlay'] as bool? ?? false,
      supportsDirectStream: json['SupportsDirectStream'] as bool? ?? false,
      supportsTranscoding: json['SupportsTranscoding'] as bool? ?? false,
      transcodingUrl: json['TranscodingUrl'] as String?,
      mediaStreams:
          (json['MediaStreams'] as List<dynamic>?)
              ?.map((e) => MediaStream.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      defaultAudioStreamIndex: (json['DefaultAudioStreamIndex'] as num?)
          ?.toInt(),
      defaultSubtitleStreamIndex: (json['DefaultSubtitleStreamIndex'] as num?)
          ?.toInt(),
    );

const _$MediaSourceInfoFieldMap = <String, String>{
  'id': 'Id',
  'container': 'Container',
  'runTimeTicks': 'RunTimeTicks',
  'supportsDirectPlay': 'SupportsDirectPlay',
  'supportsDirectStream': 'SupportsDirectStream',
  'supportsTranscoding': 'SupportsTranscoding',
  'transcodingUrl': 'TranscodingUrl',
  'mediaStreams': 'MediaStreams',
  'defaultAudioStreamIndex': 'DefaultAudioStreamIndex',
  'defaultSubtitleStreamIndex': 'DefaultSubtitleStreamIndex',
};

Map<String, dynamic> _$MediaSourceInfoToJson(_MediaSourceInfo instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Container': ?instance.container,
      'RunTimeTicks': ?instance.runTimeTicks,
      'SupportsDirectPlay': instance.supportsDirectPlay,
      'SupportsDirectStream': instance.supportsDirectStream,
      'SupportsTranscoding': instance.supportsTranscoding,
      'TranscodingUrl': ?instance.transcodingUrl,
      'MediaStreams': instance.mediaStreams.map((e) => e.toJson()).toList(),
      'DefaultAudioStreamIndex': ?instance.defaultAudioStreamIndex,
      'DefaultSubtitleStreamIndex': ?instance.defaultSubtitleStreamIndex,
    };
