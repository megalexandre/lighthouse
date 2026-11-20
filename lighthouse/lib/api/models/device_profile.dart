import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'device_profile.freezed.dart';
part 'device_profile.g.dart';

/// What this client can play, sent with PlaybackInfo so the server can
/// decide between direct play and a transcode. Only the parts the app
/// fills are modelled.
@Freezed(toJson: true)
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
@Freezed(toJson: true)
abstract class DirectPlayProfile with _$DirectPlayProfile {
  const factory DirectPlayProfile({
    required String type,
    String? container,
    String? videoCodec,
    String? audioCodec,
  }) = _DirectPlayProfile;

  static const jsonShape = JsonShape(_$DirectPlayProfileFieldMap);
}

/// What to transcode to when direct play is not possible.
@Freezed(toJson: true)
abstract class TranscodingProfile with _$TranscodingProfile {
  const factory TranscodingProfile({
    required String type,
    String? container,
    String? protocol,
    String? videoCodec,
    String? audioCodec,
    String? maxAudioChannels,
  }) = _TranscodingProfile;

  static const jsonShape = JsonShape(_$TranscodingProfileFieldMap);
}

/// A subtitle format and how the player takes it (Embed, External...).
@Freezed(toJson: true)
abstract class SubtitleProfile with _$SubtitleProfile {
  const factory SubtitleProfile({
    required String format,
    required String method,
  }) = _SubtitleProfile;

  static const jsonShape = JsonShape(_$SubtitleProfileFieldMap);
}
