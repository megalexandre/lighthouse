import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see a line {'No bookmarks yet'}
///
/// A text that has that in it.
Future<void> iSeeALine(WidgetTester tester, String text) async {
  expect(find.textContaining(text), findsOneWidget);
}
