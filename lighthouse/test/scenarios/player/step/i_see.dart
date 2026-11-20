import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see {'Resume from 1:04'}
///
/// The text, once, anywhere on the screen.
Future<void> iSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsOneWidget);
}
