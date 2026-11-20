import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then it is at {10} seconds
Future<void> itIsAtSeconds(WidgetTester tester, num seconds) async {
  expect(app.engine.position, Duration(seconds: seconds.toInt()));
}
