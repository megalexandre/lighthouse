import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then there is no {'next'} button
Future<void> thereIsNoButton(WidgetTester tester, String name) async {
  expect(find.byKey(buttons[name]!), findsNothing);
}
