// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

const _$SubtitleProfileFieldMap = <String, String>{
  'format': 'Format',
  'method': 'Method',
};

Map<String, dynamic> _$SubtitleProfileToJson(_SubtitleProfile instance) =>
    <String, dynamic>{'Format': instance.format, 'Method': instance.method};
