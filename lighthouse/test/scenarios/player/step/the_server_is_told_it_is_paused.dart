import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told it is paused
Future<void> theServerIsToldItIsPaused(WidgetTester tester) async {
  expect(app.playback.progress.last.isPaused, isTrue);
}
