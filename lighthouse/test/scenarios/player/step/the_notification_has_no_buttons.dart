import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the notification has no buttons
///
/// The player is locked: the song and its cover only.
Future<void> theNotificationHasNoButtons(WidgetTester tester) async {
  expect(app.mediaControls.item, isNotNull);
  expect(app.mediaControls.state?.locked, isTrue);
}
