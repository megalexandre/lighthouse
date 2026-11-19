import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the {'Portuguese'} audio track plays
///
/// mpv's id of the fake movie's audio tracks (FakePlaybackRepository.streams:
/// English first, then Portuguese), as the player picked it.
Future<void> theAudioTrackPlays(WidgetTester tester, String language) async {
  const mpvIds = {'English': '1', 'Portuguese': '2'};
  expect(app.engine.audioTrack.id, mpvIds[language]);
}
