import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the phone is held sideways
///
/// The picture's way, however the phone is.
Future<void> thePhoneIsHeldSideways(WidgetTester tester) async {
  expect(app.window.isLandscape, isTrue);
}
