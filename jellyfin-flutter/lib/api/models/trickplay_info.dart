import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'trickplay_info.freezed.dart';
part 'trickplay_info.g.dart';

/// How a video's seek-bar thumbnails are stored: [thumbnailCount] pictures
/// of [width] × [height], one every [interval] ms, laid out [tileWidth] ×
/// [tileHeight] to an image file (a "tile"), left to right, top to bottom.
@freezed
abstract class TrickplayInfo with _$TrickplayInfo {
  const factory TrickplayInfo({
    required int width,
    required int height,
    required int tileWidth,
    required int tileHeight,
    required int thumbnailCount,
    required int interval,
  }) = _TrickplayInfo;

  const TrickplayInfo._();

  factory TrickplayInfo.fromJson(Map<String, dynamic> json) =>
      _$TrickplayInfoFromJson(json);

  static const jsonShape = JsonShape(_$TrickplayInfoFieldMap);

  int get perTile => tileWidth * tileHeight;

  /// The thumbnail shown at [position]: its tile file, and where it sits
  /// in it (pixels). Null when there is none (no thumbnails).
  ({int tile, int x, int y})? at(Duration position) {
    if (thumbnailCount <= 0 || interval <= 0 || perTile <= 0) return null;
    final n = (position.inMilliseconds ~/ interval).clamp(
      0,
      thumbnailCount - 1,
    );
    final inTile = n % perTile;
    return (
      tile: n ~/ perTile,
      x: (inTile % tileWidth) * width,
      y: (inTile ~/ tileWidth) * height,
    );
  }
}
