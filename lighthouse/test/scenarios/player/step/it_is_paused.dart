import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then it is paused
Future<void> itIsPaused(WidgetTester tester) async {
  expect(app.engine.playing, isFalse);
}
