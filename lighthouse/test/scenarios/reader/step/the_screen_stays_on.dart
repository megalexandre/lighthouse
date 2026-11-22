import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the screen stays on
Future<void> theScreenStaysOn(WidgetTester tester) async {
  expect(app.window.staysOn, isTrue);
}
