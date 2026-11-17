import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'media_stream.freezed.dart';
part 'media_stream.g.dart';

@JsonEnum(fieldRename: FieldRename.pascal)
enum MediaStreamType {
  audio,
  video,
  subtitle,
  embeddedImage,
  data,
  lyric,
  unknown,
}

/// How a subtitle reaches the player.
@JsonEnum(fieldRename: FieldRename.pascal)
enum SubtitleDeliveryMethod {
  /// Burnt into the video by a transcode.
  encode,

  /// Inside the file: the player picks it among the file's tracks.
  embed,

  /// A separate file, fetched from [MediaStream.deliveryUrl].
  external,
  hls,
  drop,
  unknown,
}

/// One track of a media source (video, an audio language, a subtitle).
/// [index] is the server's numbering, used in PlaybackInfo and reports; it
/// is not the player's track number.
@freezed
abstract class MediaStream with _$MediaStream {
  const factory MediaStream({
    required int index,
    @JsonKey(unknownEnumValue: MediaStreamType.unknown)
    required MediaStreamType type,
    String? codec,
    String? language,
    String? title,

    /// Ready-made label, e.g. "English - AAC - Mono - Default".
    String? displayTitle,
    @Default(false) bool isExternal,
    @Default(false) bool isDefault,
    @Default(false) bool isForced,
    @JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown)
    SubtitleDeliveryMethod? deliveryMethod,

    /// Server-relative URL of an external subtitle. It carries an access
    /// token: never log it.
    String? deliveryUrl,
    int? channels,

    /// Video: its size, and SDR / HDR10 / HDR10Plus / HLG / DOVI...
    int? width,
    int? height,
    String? videoRangeType,
  }) = _MediaStream;

  factory MediaStream.fromJson(Map<String, dynamic> json) =>
      _$MediaStreamFromJson(json);

  static const jsonShape = JsonShape(_$MediaStreamFieldMap);
}
