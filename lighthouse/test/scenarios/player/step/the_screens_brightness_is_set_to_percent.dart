import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the screen's brightness is set to {50} percent
///
/// The screen's own (the phone's setting); the app's window sets none.
Future<void> theScreensBrightnessIsSetToPercent(
  WidgetTester tester,
  num percent,
) async {
  app.levels.screenBrightness = percent / 100;
}
