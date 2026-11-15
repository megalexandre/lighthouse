import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'media_source_info.dart';

part 'playback_info_response.freezed.dart';
part 'playback_info_response.g.dart';

/// The server's answer to "how can this client play this item".
@freezed
abstract class PlaybackInfoResponse with _$PlaybackInfoResponse {
  const factory PlaybackInfoResponse({
    @Default([]) List<MediaSourceInfo> mediaSources,

    /// Identifies this playback in the progress reports.
    String? playSessionId,

    /// Why it cannot be played (NotAllowed, NoCompatibleStream...).
    String? errorCode,
  }) = _PlaybackInfoResponse;

  factory PlaybackInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$PlaybackInfoResponseFromJson(json);

  static const jsonShape = JsonShape(
    _$PlaybackInfoResponseFieldMap,
    nested: {'MediaSources': MediaSourceInfo.jsonShape},
  );
}
