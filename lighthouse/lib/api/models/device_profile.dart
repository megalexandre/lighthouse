import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'device_profile.freezed.dart';
part 'device_profile.g.dart';

/// What this client can play, sent with PlaybackInfo so the server can
/// decide between direct play and a transcode. Only the parts the app
/// fills are modelled.
@freezed
abstract class DeviceProfile with _$DeviceProfile {
  const factory DeviceProfile({
    required String name,
    int? maxStaticBitrate,
    int? maxStreamingBitrate,
    int? musicStreamingTranscodingBitrate,
    @Default([]) List<DirectPlayProfile> directPlayProfiles,
    @Default([]) List<TranscodingProfile> transcodingProfiles,
    @Default([]) List<SubtitleProfile> subtitleProfiles,
  }) = _DeviceProfile;

  factory DeviceProfile.fromJson(Map<String, dynamic> json) =>
      _$DeviceProfileFromJson(json);

  static const jsonShape = JsonShape(
    _$DeviceProfileFieldMap,
    nested: {
      'DirectPlayProfiles': DirectPlayProfile.jsonShape,
      'TranscodingProfiles': TranscodingProfile.jsonShape,
      'SubtitleProfiles': SubtitleProfile.jsonShape,
    },
  );
}

/// Played as-is. Empty container/codecs mean "any".
@freezed
abstract class DirectPlayProfile with _$DirectPlayProfile {
  const factory DirectPlayProfile({
    required String type,
    String? container,
    String? videoCodec,
    String? audioCodec,
  }) = _DirectPlayProfile;

  factory DirectPlayProfile.fromJson(Map<String, dynamic> json) =>
      _$DirectPlayProfileFromJson(json);

  static const jsonShape = JsonShape(_$DirectPlayProfileFieldMap);
}

/// What to transcode to when direct play is not possible.
@freezed
abstract class TranscodingProfile with _$TranscodingProfile {
  const factory TranscodingProfile({
    required String type,
    String? container,
    String? protocol,
    String? videoCodec,
    String? audioCodec,
    String? maxAudioChannels,
  }) = _TranscodingProfile;

  factory TranscodingProfile.fromJson(Map<String, dynamic> json) =>
      _$TranscodingProfileFromJson(json);

  static const jsonShape = JsonShape(_$TranscodingProfileFieldMap);
}

/// A subtitle format and how the player takes it (Embed, External...).
@freezed
abstract class SubtitleProfile with _$SubtitleProfile {
  const factory SubtitleProfile({
    required String format,
    required String method,
  }) = _SubtitleProfile;

  factory SubtitleProfile.fromJson(Map<String, dynamic> json) =>
      _$SubtitleProfileFromJson(json);

  static const jsonShape = JsonShape(_$SubtitleProfileFieldMap);
}
