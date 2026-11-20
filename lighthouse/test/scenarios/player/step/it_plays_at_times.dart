import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then it plays at {1.5} times
Future<void> itPlaysAtTimes(WidgetTester tester, num rate) async {
  expect(app.engine.rate, rate);
}
