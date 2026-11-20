import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: Then the card of {'Test Movie'} shows a check
///
/// It was watched.
Future<void> theCardOfShowsACheck(WidgetTester tester, String name) async {
  expect(
    find.descendant(of: cardOf(name), matching: find.byIcon(Icons.check)),
    findsOneWidget,
  );
}
