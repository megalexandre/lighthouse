// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserConfiguration _$UserConfigurationFromJson(Map<String, dynamic> json) =>
    _UserConfiguration(
      audioLanguagePreference: json['AudioLanguagePreference'] as String?,
      subtitleLanguagePreference: json['SubtitleLanguagePreference'] as String?,
      subtitleMode:
          $enumDecodeNullable(
            _$SubtitlePlaybackModeEnumMap,
            json['SubtitleMode'],
            unknownValue: SubtitlePlaybackMode.defaultMode,
          ) ??
          SubtitlePlaybackMode.defaultMode,
      playDefaultAudioTrack: json['PlayDefaultAudioTrack'] as bool? ?? true,
      enableNextEpisodeAutoPlay:
          json['EnableNextEpisodeAutoPlay'] as bool? ?? true,
    );

const _$UserConfigurationFieldMap = <String, String>{
  'audioLanguagePreference': 'AudioLanguagePreference',
  'subtitleLanguagePreference': 'SubtitleLanguagePreference',
  'subtitleMode': 'SubtitleMode',
  'playDefaultAudioTrack': 'PlayDefaultAudioTrack',
  'enableNextEpisodeAutoPlay': 'EnableNextEpisodeAutoPlay',
};

Map<String, dynamic> _$UserConfigurationToJson(_UserConfiguration instance) =>
    <String, dynamic>{
      'AudioLanguagePreference': ?instance.audioLanguagePreference,
      'SubtitleLanguagePreference': ?instance.subtitleLanguagePreference,
      'SubtitleMode': _$SubtitlePlaybackModeEnumMap[instance.subtitleMode]!,
      'PlayDefaultAudioTrack': instance.playDefaultAudioTrack,
      'EnableNextEpisodeAutoPlay': instance.enableNextEpisodeAutoPlay,
    };

const _$SubtitlePlaybackModeEnumMap = {
  SubtitlePlaybackMode.defaultMode: 'Default',
  SubtitlePlaybackMode.always: 'Always',
  SubtitlePlaybackMode.onlyForced: 'OnlyForced',
  SubtitlePlaybackMode.none: 'None',
  SubtitlePlaybackMode.smart: 'Smart',
};
