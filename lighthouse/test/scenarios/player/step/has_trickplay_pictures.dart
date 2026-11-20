import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/trickplay_info.dart';

import 'world.dart';

/// Usage: Given {'movie-1'} has trickplay pictures
///
/// One a minute, nine to a tile, as the server makes them; every tile is
/// a real PNG.
Future<void> hasTrickplayPictures(WidgetTester tester, String itemId) async {
  const info = TrickplayInfo(
    width: 160,
    height: 90,
    tileWidth: 3,
    tileHeight: 3,
    thumbnailCount: 10,
    interval: 60000,
  );
  app.library.movies = [
    for (final m in app.library.movies)
      m.id == itemId
          ? m.copyWith(
              trickplay: {
                itemId: {'160': info},
              },
            )
          : m,
  ];
  // Real image work: off the test's fake clock.
  app.playback.tile = await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xFF336699), ui.BlendMode.src);
    final image = await recorder.endRecording().toImage(480, 270);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return png!.buffer.asUint8List();
  });
}
