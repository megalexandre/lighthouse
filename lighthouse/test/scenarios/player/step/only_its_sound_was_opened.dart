import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And only its sound was opened
///
/// Not its embedded cover, which would need a surface.
Future<void> onlyItsSoundWasOpened(WidgetTester tester) async {
  expect(app.engine.openedVideo, isFalse);
}
