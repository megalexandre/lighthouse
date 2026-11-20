import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the window is not full screen
Future<void> theWindowIsNotFullScreen(WidgetTester tester) async {
  expect(app.window.isFullScreen, isFalse);
}
