import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the screen's brightness is {75} percent
///
/// The app's window's, set by the app.
Future<void> theScreensBrightnessIsPercent(
  WidgetTester tester,
  num percent,
) async {
  expect(app.levels.brightnessLevel, isNotNull);
  expect(
    app.levels.brightnessLevel! * 100,
    moreOrLessEquals(percent.toDouble()),
  );
}
