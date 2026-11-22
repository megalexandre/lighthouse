import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the notification is at {30} seconds
Future<void> theNotificationIsAtSeconds(
  WidgetTester tester,
  num seconds,
) async {
  expect(app.mediaControls.state?.position, Duration(seconds: seconds.toInt()));
}
