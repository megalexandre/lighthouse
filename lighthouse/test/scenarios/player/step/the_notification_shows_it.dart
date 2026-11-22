import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the notification shows it {'playing'}
///
/// Playing or paused.
Future<void> theNotificationShowsIt(WidgetTester tester, String state) async {
  expect(app.mediaControls.state?.playing, state == 'playing');
}
