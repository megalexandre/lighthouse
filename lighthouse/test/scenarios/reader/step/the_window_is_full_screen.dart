import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the window is full screen
Future<void> theWindowIsFullScreen(WidgetTester tester) async {
  expect(app.window.isFullScreen, isTrue);
}
