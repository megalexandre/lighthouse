import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then it seeks once, to {300} seconds
///
/// Where the drag ended: not on the way there.
Future<void> itSeeksOnceToSeconds(WidgetTester tester, num seconds) async {
  expect(app.engine.seeks, [Duration(seconds: seconds.toInt())]);
}
