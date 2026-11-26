import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the screen is back to its own brightness
///
/// The window sets none any more.
Future<void> theScreenIsBackToItsOwnBrightness(WidgetTester tester) async {
  expect(app.levels.brightnessLevel, isNull);
}
