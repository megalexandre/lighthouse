import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the {'Portuguese'} subtitle is shown
///
/// The fake movie's subtitles: Portuguese is a file beside it, which mpv
/// is given to download; English is in the file, mpv's subtitle 1.
Future<void> theSubtitleIsShown(WidgetTester tester, String language) async {
  final track = app.engine.subtitleTrack;
  switch (language) {
    case 'Portuguese':
      expect(track.id, contains('/Subtitles/0/0/Stream.subrip'));
      expect(track.language, 'por');
    case 'English':
      expect(track.id, '1');
    default:
      fail('The fake movie has no $language subtitle');
  }
}
