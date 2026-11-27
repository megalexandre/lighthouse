import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the floating window is {2.4} times as wide as high
Future<void> theFloatingWindowIsTimesAsWideAsHigh(
  WidgetTester tester,
  num ratio,
) async {
  expect(app.floating.aspectRatio, closeTo(ratio, 0.01));
}
