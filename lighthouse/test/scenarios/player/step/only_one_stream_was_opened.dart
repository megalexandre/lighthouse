import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And only one stream was opened
///
/// The one playing from the start: it plays on.
Future<void> onlyOneStreamWasOpened(WidgetTester tester) async {
  expect(app.engine.opened, hasLength(1));
  expect(app.playback.stopped, isEmpty);
}
