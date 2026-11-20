import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told {'movie-1'} started
///
/// With the stream it was given: the file, signed in.
Future<void> theServerIsToldStarted(WidgetTester tester, String itemId) async {
  expect(app.playback.started.single.itemId, itemId);
  expect(app.engine.openedHeaders, contains('Authorization'));
}
