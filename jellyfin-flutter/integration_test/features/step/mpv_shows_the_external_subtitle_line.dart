import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: Then mpv shows the external subtitle line {'Português subtitle one'}
///
/// Accents intact (the fixture has a BOM).
Future<void> mpvShowsTheExternalSubtitleLine(
  WidgetTester tester,
  String line,
) async {
  await mpvShows(tester, 'current-tracks/sub/external', 'yes');
  await mpvShows(tester, 'sub-text', line);
}
