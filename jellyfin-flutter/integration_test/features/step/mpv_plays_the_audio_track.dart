import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: Then mpv plays the {'por'} audio track
Future<void> mpvPlaysTheAudioTrack(WidgetTester tester, String language) async {
  await mpvShows(tester, 'current-tracks/audio/lang', language);
}
