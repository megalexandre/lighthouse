import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the phone's bars are hidden
///
/// The status and navigation bars: the app is full screen (immersive mode
/// on Android, through the fake window).
Future<void> thePhonesBarsAreHidden(WidgetTester tester) async {
  expect(app.window.isFullScreen, isTrue);
}
