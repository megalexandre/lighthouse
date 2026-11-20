import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps next episode autoplay off
Future<void> theServerKeepsNextEpisodeAutoplayOff(WidgetTester tester) async {
  expect(app.settings.config.enableNextEpisodeAutoPlay, isFalse);
}
