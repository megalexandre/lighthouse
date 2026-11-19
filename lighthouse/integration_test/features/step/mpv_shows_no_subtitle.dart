import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: Then mpv shows no subtitle
Future<void> mpvShowsNoSubtitle(WidgetTester tester) async {
  await mpvShows(tester, 'sid', 'no');
}
