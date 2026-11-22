import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the stream of {'track-2'} is open
///
/// And playing.
Future<void> theStreamOfIsOpen(WidgetTester tester, String itemId) async {
  expect(app.engine.openedUrl?.pathSegments, contains(itemId));
  expect(app.engine.playing, isTrue);
}
