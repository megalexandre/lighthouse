import 'package:flutter_test/flutter_test.dart';

/// Usage: And I do not see {'Back to page 1'}
Future<void> iDoNotSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}
