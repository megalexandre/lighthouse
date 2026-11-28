import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the page swished {1} times
///
/// One swish per page turned, since the book opened.
Future<void> thePageSwishedTimes(WidgetTester tester, int times) async {
  expect(app.pageSounds.turns, times);
}
