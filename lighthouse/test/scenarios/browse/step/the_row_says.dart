import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the {'Latest in Movies'} row says {'Cannot reach ...'}
///
/// In place of its cards.
Future<void> theRowSays(WidgetTester tester, String title, String text) async {
  expect(
    find.descendant(
      of: await rowOnScreen(tester, title),
      matching: find.text(text),
    ),
    findsOneWidget,
  );
}
