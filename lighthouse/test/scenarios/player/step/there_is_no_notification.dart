import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then there is no notification
Future<void> thereIsNoNotification(WidgetTester tester) async {
  expect(app.mediaControls.item, isNull);
}
