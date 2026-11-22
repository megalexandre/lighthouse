import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the screen may turn off
Future<void> theScreenMayTurnOff(WidgetTester tester) async {
  expect(app.window.staysOn, isFalse);
}
