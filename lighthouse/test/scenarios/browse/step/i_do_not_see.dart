import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I do not see {'Movie 249'}
Future<void> iDoNotSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}
