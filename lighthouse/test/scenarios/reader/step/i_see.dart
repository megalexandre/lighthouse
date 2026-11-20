import 'package:flutter_test/flutter_test.dart';

/// Usage: Then I see {'Continue reading · 40%'}
///
/// The text, once, anywhere on the screen.
Future<void> iSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsOneWidget);
}
