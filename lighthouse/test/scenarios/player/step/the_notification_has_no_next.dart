import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the notification has no next
Future<void> theNotificationHasNoNext(WidgetTester tester) async {
  expect(app.mediaControls.state?.hasNext, isFalse);
}
