import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'user_configuration.freezed.dart';
part 'user_configuration.g.dart';

/// When subtitles show, by the user's server setting.
@JsonEnum(fieldRename: FieldRename.pascal)
enum SubtitlePlaybackMode {
  /// Only when the file marks a subtitle as default or forced.
  @JsonValue('Default')
  defaultMode,

  /// Always, in the preferred language.
  always,

  /// Only forced subtitles (signs, foreign dialogue).
  onlyForced,

  /// Never.
  none,

  /// When the audio is not in the preferred language.
  smart,
}

/// The playback part of a user's settings, kept on the server so every
/// client follows them. The server applies the language preferences
/// itself when it answers PlaybackInfo (the default audio / subtitle).
@freezed
abstract class UserConfiguration with _$UserConfiguration {
  const factory UserConfiguration({
    /// ISO 639-2 code (e.g. "por"); null or empty = the file's default.
    String? audioLanguagePreference,
    String? subtitleLanguagePreference,
    @JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode)
    @Default(SubtitlePlaybackMode.defaultMode)
    SubtitlePlaybackMode subtitleMode,
    @Default(true) bool playDefaultAudioTrack,
    @Default(true) bool enableNextEpisodeAutoPlay,
  }) = _UserConfiguration;

  factory UserConfiguration.fromJson(Map<String, dynamic> json) =>
      _$UserConfigurationFromJson(json);

  static const jsonShape = JsonShape(_$UserConfigurationFieldMap);
}
