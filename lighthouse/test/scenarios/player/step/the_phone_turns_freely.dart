import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the phone turns freely
Future<void> thePhoneTurnsFreely(WidgetTester tester) async {
  expect(app.window.isLandscape, isFalse);
}
