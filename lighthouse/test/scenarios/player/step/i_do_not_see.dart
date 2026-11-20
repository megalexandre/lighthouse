import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I do not see {'Resume from 0:30'}
Future<void> iDoNotSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}
