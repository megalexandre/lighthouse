import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../support/app.dart';
import '../../support/player.dart';

/// Usage: Then mpv draws at the size the video takes on screen
///
/// In physical pixels: mpv scales the picture, not Flutter stretching a
/// texture at the video's own size (which came out jagged).
Future<void> mpvDrawsAtTheSizeTheVideoTakesOnScreen(WidgetTester tester) async {
  final engine = mpvEngine(tester);
  final video = find.byType(Video);
  final ratio = tester.view.devicePixelRatio;
  final size = tester.getSize(video) * ratio;
  final expected = '${size.width.round()}x${size.height.round()}';
  var drawn = '';
  await waitUntil(
    tester,
    () => drawn == expected,
    reason: 'mpv drawing at $expected (it draws at $drawn)',
    poll: () async => drawn =
        '${await engine.mpvProperty('osd-width')}'
        'x${await engine.mpvProperty('osd-height')}',
  );
}
