import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'media_stream.dart';

part 'media_source_info.freezed.dart';
part 'media_source_info.g.dart';

/// One playable version of an item (a file, or a server-made stream), with
/// what the server allows this client to do with it.
@freezed
abstract class MediaSourceInfo with _$MediaSourceInfo {
  const factory MediaSourceInfo({
    required String id,
    String? container,
    int? runTimeTicks,
    @Default(false) bool supportsDirectPlay,
    @Default(false) bool supportsDirectStream,
    @Default(false) bool supportsTranscoding,

    /// Server-relative URL of a transcoded stream, when the server decided
    /// one is needed. It carries an access token: never log it.
    String? transcodingUrl,
    @Default([]) List<MediaStream> mediaStreams,
    int? defaultAudioStreamIndex,
    int? defaultSubtitleStreamIndex,
  }) = _MediaSourceInfo;

  factory MediaSourceInfo.fromJson(Map<String, dynamic> json) =>
      _$MediaSourceInfoFromJson(json);

  static const jsonShape = JsonShape(
    _$MediaSourceInfoFieldMap,
    nested: {'MediaStreams': MediaStream.jsonShape},
  );
}
