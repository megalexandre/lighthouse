import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the player is full screen
Future<void> thePlayerIsFullScreen(WidgetTester tester) async {
  expect(app.window.isFullScreen, isTrue);
}
