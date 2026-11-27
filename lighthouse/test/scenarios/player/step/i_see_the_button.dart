import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then I see the {'unlock'} button
///
/// One of [buttons].
Future<void> iSeeTheButton(WidgetTester tester, String name) async {
  expect(find.byKey(buttons[name]!), findsOneWidget);
}
