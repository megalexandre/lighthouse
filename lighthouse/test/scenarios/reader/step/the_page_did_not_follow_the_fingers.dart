import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the page did not follow the fingers
///
/// No sheet lifted during the last touchpad swipe before it was long
/// enough to turn the page.
Future<void> thePageDidNotFollowTheFingers(WidgetTester tester) async {
  expect(liftedMidSwipe, isFalse);
}
