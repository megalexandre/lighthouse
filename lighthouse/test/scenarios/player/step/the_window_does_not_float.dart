import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the window does not float
Future<void> theWindowDoesNotFloat(WidgetTester tester) async {
  expect(app.floating.floating, isFalse);
}
