import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see a line {'broken.json: not used'}
///
/// A text that starts with, or has, that.
Future<void> iSeeALine(WidgetTester tester, String text) async {
  expect(find.textContaining(text), findsOneWidget);
}
