import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the phone's bars are shown
///
/// The status and navigation bars: the app is not full screen.
Future<void> thePhonesBarsAreShown(WidgetTester tester) async {
  expect(app.window.isFullScreen, isFalse);
}
