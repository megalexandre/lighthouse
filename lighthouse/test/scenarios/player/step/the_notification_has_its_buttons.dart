import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the notification has its buttons
Future<void> theNotificationHasItsButtons(WidgetTester tester) async {
  expect(app.mediaControls.item, isNotNull);
  expect(app.mediaControls.state?.locked, isFalse);
}
