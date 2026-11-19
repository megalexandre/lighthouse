import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'playback_report.freezed.dart';
part 'playback_report.g.dart';

/// How the media reaches the player, as the server counts it.
@JsonEnum(fieldRename: FieldRename.pascal)
enum PlayMethod { directPlay, directStream, transcode }

/// Body of the start and progress reports (`POST /Sessions/Playing` and
/// `/Sessions/Playing/Progress`): where playback is and in which state.
@freezed
abstract class PlaybackProgressInfo with _$PlaybackProgressInfo {
  const factory PlaybackProgressInfo({
    required String itemId,
    required String mediaSourceId,
    String? playSessionId,
    required int positionTicks,
    @Default(false) bool isPaused,
    @Default(false) bool isMuted,
    @Default(true) bool canSeek,
    required PlayMethod playMethod,
    int? audioStreamIndex,
    int? subtitleStreamIndex,

    /// 0–100.
    int? volumeLevel,
  }) = _PlaybackProgressInfo;

  factory PlaybackProgressInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaybackProgressInfoFromJson(json);

  static const jsonShape = JsonShape(_$PlaybackProgressInfoFieldMap);
}

/// Body of `POST /Sessions/Playing/Stopped`. The server saves
/// [positionTicks] as the resume point, or marks the item watched when it
/// is near the end.
@freezed
abstract class PlaybackStopInfo with _$PlaybackStopInfo {
  const factory PlaybackStopInfo({
    required String itemId,
    required String mediaSourceId,
    String? playSessionId,
    required int positionTicks,
    @Default(false) bool failed,
  }) = _PlaybackStopInfo;

  factory PlaybackStopInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaybackStopInfoFromJson(json);

  static const jsonShape = JsonShape(_$PlaybackStopInfoFieldMap);
}
