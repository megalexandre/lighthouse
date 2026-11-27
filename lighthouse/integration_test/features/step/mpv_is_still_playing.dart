import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: Then mpv is still playing
///
/// A moment after, for a pause that would come to reach mpv.
Future<void> mpvIsStillPlaying(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  expect(await mpvEngine(tester).mpvProperty('pause'), 'no');
}
