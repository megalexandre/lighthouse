import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then I see {'Test Movie'} in the {'Latest in Movies'} row
Future<void> iSeeInTheRow(
  WidgetTester tester,
  String text,
  String title,
) async {
  expect(
    find.descendant(of: row(title), matching: find.text(text)),
    findsOneWidget,
  );
}
