import 'dart:async';
import 'dart:ui' as ui;

import '../../../api/models/base_item_dto.dart';
import '../../../api/models/trickplay_info.dart';
import '../../../core/log.dart';
import '../data/playback_repository.dart';

/// One seek-bar thumbnail: [image] is its whole tile, [source] the part
/// that is this picture.
typedef Thumbnail = ({ui.Image image, ui.Rect source});

/// The seek-bar thumbnails of what is playing: tiles fetched when first
/// needed, a few kept decoded (a tile holds many pictures; scrubbing stays
/// within one or two).
class TrickplayThumbnails {
  TrickplayThumbnails._(this._itemId, this._sourceId, this.info, this._fetch);

  /// The thumbnails of [item]'s [mediaSourceId], at the width closest to
  /// the 160 px the seek bar shows; null when the server made none.
  static TrickplayThumbnails? of(
    BaseItemDto item,
    String mediaSourceId,
    PlaybackRepository repository,
  ) {
    final widths =
        item.trickplay[mediaSourceId] ?? item.trickplay.values.firstOrNull;
    if (widths == null || widths.isEmpty) return null;
    final infos = widths.values.toList()
      ..sort((a, b) => a.width.compareTo(b.width));
    final info = infos.firstWhere(
      (i) => i.width >= shownWidth,
      orElse: () => infos.last,
    );
    if (info.thumbnailCount <= 0) return null;
    return TrickplayThumbnails._(
      item.id,
      item.trickplay.containsKey(mediaSourceId)
          ? mediaSourceId
          : item.trickplay.keys.first,
      info,
      repository,
    );
  }

  /// How wide the seek bar shows a thumbnail.
  static const shownWidth = 160;

  /// Decoded tiles kept (each up to a few MB of pixels).
  static const _keep = 3;

  final String _itemId;
  final String _sourceId;
  final TrickplayInfo info;
  final PlaybackRepository _fetch;

  final _tiles = <int, ui.Image>{};
  final _loading = <int, Future<ui.Image?>>{};
  final _failed = <int>{};
  bool _disposed = false;

  /// Width ÷ height of a thumbnail.
  double get aspectRatio =>
      info.height == 0 ? 16 / 9 : info.width / info.height;

  /// The thumbnail at [position] if its tile is loaded; else null (see
  /// [load]).
  Thumbnail? at(Duration position) {
    final place = info.at(position);
    if (place == null) return null;
    final image = _tiles[place.tile];
    if (image == null) return null;
    // Most recently used: last.
    _tiles
      ..remove(place.tile)
      ..[place.tile] = image;
    return (
      image: image,
      source: ui.Rect.fromLTWH(
        place.x.toDouble(),
        place.y.toDouble(),
        info.width.toDouble(),
        info.height.toDouble(),
      ),
    );
  }

  /// Loads the tile of [position]; completes with its thumbnail (null when
  /// it cannot be had).
  Future<Thumbnail?> load(Duration position) async {
    final place = info.at(position);
    if (place == null || _failed.contains(place.tile)) return null;
    if (!_tiles.containsKey(place.tile)) {
      final image = await _loading.putIfAbsent(
        place.tile,
        () => _decode(place.tile),
      );
      unawaited(_loading.remove(place.tile)); // Done: awaited just above.
      if (_disposed || image == null) return null;
      if (!_tiles.containsKey(place.tile)) {
        _tiles[place.tile] = image;
        while (_tiles.length > _keep) {
          _tiles.remove(_tiles.keys.first)?.dispose();
        }
      }
    }
    return at(position);
  }

  Future<ui.Image?> _decode(int tile) async {
    try {
      final bytes = await _fetch.trickplayTile(
        _itemId,
        mediaSourceId: _sourceId,
        width: info.width,
        index: tile,
      );
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } on Object catch (e) {
      // Thumbnails are a nicety: the bar works without them.
      _failed.add(tile);
      log.warning('player', 'trickplay tile $tile unavailable', e);
      return null;
    }
  }

  void dispose() {
    _disposed = true;
    for (final image in _tiles.values) {
      image.dispose();
    }
    _tiles.clear();
  }
}
