import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the notification shows {'Track 1'}
Future<void> theNotificationShows(WidgetTester tester, String title) async {
  expect(app.mediaControls.item?.title, title);
}
