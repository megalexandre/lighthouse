// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceProfile _$DeviceProfileFromJson(
  Map<String, dynamic> json,
) => _DeviceProfile(
  name: json['Name'] as String,
  maxStaticBitrate: (json['MaxStaticBitrate'] as num?)?.toInt(),
  maxStreamingBitrate: (json['MaxStreamingBitrate'] as num?)?.toInt(),
  musicStreamingTranscodingBitrate:
      (json['MusicStreamingTranscodingBitrate'] as num?)?.toInt(),
  directPlayProfiles:
      (json['DirectPlayProfiles'] as List<dynamic>?)
          ?.map((e) => DirectPlayProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  transcodingProfiles:
      (json['TranscodingProfiles'] as List<dynamic>?)
          ?.map((e) => TranscodingProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subtitleProfiles:
      (json['SubtitleProfiles'] as List<dynamic>?)
          ?.map((e) => SubtitleProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

const _$DeviceProfileFieldMap = <String, String>{
  'name': 'Name',
  'maxStaticBitrate': 'MaxStaticBitrate',
  'maxStreamingBitrate': 'MaxStreamingBitrate',
  'musicStreamingTranscodingBitrate': 'MusicStreamingTranscodingBitrate',
  'directPlayProfiles': 'DirectPlayProfiles',
  'transcodingProfiles': 'TranscodingProfiles',
  'subtitleProfiles': 'SubtitleProfiles',
};

Map<String, dynamic> _$DeviceProfileToJson(
  _DeviceProfile instance,
) => <String, dynamic>{
  'Name': instance.name,
  'MaxStaticBitrate': ?instance.maxStaticBitrate,
  'MaxStreamingBitrate': ?instance.maxStreamingBitrate,
  'MusicStreamingTranscodingBitrate':
      ?instance.musicStreamingTranscodingBitrate,
  'DirectPlayProfiles': instance.directPlayProfiles
      .map((e) => e.toJson())
      .toList(),
  'TranscodingProfiles': instance.transcodingProfiles
      .map((e) => e.toJson())
      .toList(),
  'SubtitleProfiles': instance.subtitleProfiles.map((e) => e.toJson()).toList(),
};

_DirectPlayProfile _$DirectPlayProfileFromJson(Map<String, dynamic> json) =>
    _DirectPlayProfile(
      type: json['Type'] as String,
      container: json['Container'] as String?,
      videoCodec: json['VideoCodec'] as String?,
      audioCodec: json['AudioCodec'] as String?,
    );

const _$DirectPlayProfileFieldMap = <String, String>{
  'type': 'Type',
  'container': 'Container',
  'videoCodec': 'VideoCodec',
  'audioCodec': 'AudioCodec',
};

Map<String, dynamic> _$DirectPlayProfileToJson(_DirectPlayProfile instance) =>
    <String, dynamic>{
      'Type': instance.type,
      'Container': ?instance.container,
      'VideoCodec': ?instance.videoCodec,
      'AudioCodec': ?instance.audioCodec,
    };

_TranscodingProfile _$TranscodingProfileFromJson(Map<String, dynamic> json) =>
    _TranscodingProfile(
      type: json['Type'] as String,
      container: json['Container'] as String?,
      protocol: json['Protocol'] as String?,
      videoCodec: json['VideoCodec'] as String?,
      audioCodec: json['AudioCodec'] as String?,
      maxAudioChannels: json['MaxAudioChannels'] as String?,
    );

const _$TranscodingProfileFieldMap = <String, String>{
  'type': 'Type',
  'container': 'Container',
  'protocol': 'Protocol',
  'videoCodec': 'VideoCodec',
  'audioCodec': 'AudioCodec',
  'maxAudioChannels': 'MaxAudioChannels',
};

Map<String, dynamic> _$TranscodingProfileToJson(_TranscodingProfile instance) =>
    <String, dynamic>{
      'Type': instance.type,
      'Container': ?instance.container,
      'Protocol': ?instance.protocol,
      'VideoCodec': ?instance.videoCodec,
      'AudioCodec': ?instance.audioCodec,
      'MaxAudioChannels': ?instance.maxAudioChannels,
    };

_SubtitleProfile _$SubtitleProfileFromJson(Map<String, dynamic> json) =>
    _SubtitleProfile(
      format: json['Format'] as String,
      method: json['Method'] as String,
    );

const _$SubtitleProfileFieldMap = <String, String>{
  'format': 'Format',
  'method': 'Method',
};

Map<String, dynamic> _$SubtitleProfileToJson(_SubtitleProfile instance) =>
    <String, dynamic>{'Format': instance.format, 'Method': instance.method};
