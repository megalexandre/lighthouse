import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/api/models/trickplay_info.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/player/application/trickplay.dart';

import '../../support/fakes.dart';

void main() {
  // As the test server makes them: 10 pictures of 160 × 90, one a second,
  // 3 × 3 to a tile.
  const info = TrickplayInfo(
    width: 160,
    height: 90,
    tileWidth: 3,
    tileHeight: 3,
    thumbnailCount: 10,
    interval: 1000,
  );

  test('a time finds its picture: tile, then column and row', () {
    expect(info.at(Duration.zero), (tile: 0, x: 0, y: 0));
    expect(info.at(const Duration(milliseconds: 1999)), (
      tile: 0,
      x: 160,
      y: 0,
    ));
    expect(info.at(const Duration(seconds: 4)), (tile: 0, x: 160, y: 90));
    expect(info.at(const Duration(seconds: 8)), (tile: 0, x: 320, y: 180));
    expect(info.at(const Duration(seconds: 9)), (tile: 1, x: 0, y: 0));
    // Past the last picture: the last one.
    expect(info.at(const Duration(minutes: 5)), (tile: 1, x: 0, y: 0));
    expect(
      const TrickplayInfo(
        width: 1,
        height: 1,
        tileWidth: 1,
        tileHeight: 1,
        thumbnailCount: 0,
        interval: 1000,
      ).at(Duration.zero),
      isNull,
    );
  });

  BaseItemDto withTrickplay(Map<String, TrickplayInfo> widths) =>
      TestItems.testMovie.copyWith(trickplay: {'source-1': widths});

  /// A real 480 × 270 PNG (a tile).
  Future<Uint8List> tilePng() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xFF336699), ui.BlendMode.src);
    final image = await recorder.endRecording().toImage(480, 270);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return png!.buffer.asUint8List();
  }

  test('none when the server made none', () {
    final repo = FakePlaybackRepository();
    expect(
      TrickplayThumbnails.of(TestItems.testMovie, 'source-1', repo),
      isNull,
    );
  });

  test('the width closest above 160 is used; each tile fetched once', () async {
    final repo = FakePlaybackRepository()..tile = await tilePng();
    final thumbs = TrickplayThumbnails.of(
      withTrickplay({
        '320': info.copyWith(width: 320, height: 180),
        '160': info,
      }),
      'source-1',
      repo,
    )!;
    addTearDown(thumbs.dispose);
    expect(thumbs.info.width, 160);
    expect(thumbs.at(const Duration(seconds: 4)), isNull); // Not loaded yet.

    final thumb = (await thumbs.load(const Duration(seconds: 4)))!;
    expect(thumb.source, const ui.Rect.fromLTWH(160, 90, 160, 90));
    expect(thumbs.at(const Duration(seconds: 2)), isNotNull); // Same tile.
    await thumbs.load(const Duration(seconds: 9));
    expect(repo.tilesAsked, ['movie-1/160/0', 'movie-1/160/1']);
  });

  test(
    'a tile that cannot be had: no thumbnail, and not asked again',
    () async {
      final repo = FakePlaybackRepository()
        ..failures['tile'] = const ServerUnreachable(testUrl);
      final thumbs = TrickplayThumbnails.of(
        withTrickplay({'160': info}),
        'source-1',
        repo,
      )!;
      addTearDown(thumbs.dispose);
      expect(await thumbs.load(Duration.zero), isNull);
      expect(await thumbs.load(const Duration(seconds: 1)), isNull);
      expect(repo.tilesAsked, hasLength(1));
    },
  );
}
