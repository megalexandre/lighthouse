import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the accent is {'#ff8800'}
Future<void> theAccentIs(WidgetTester tester, String accent) async {
  expect(shownTheme(tester).colorScheme.primary, hex(accent));
}
