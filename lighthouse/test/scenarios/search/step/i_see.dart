import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see {'Nothing found for "zzz".'}
///
/// The text, anywhere on the screen.
Future<void> iSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsOneWidget);
}
