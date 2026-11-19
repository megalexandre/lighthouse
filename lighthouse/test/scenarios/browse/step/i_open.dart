import 'package:flutter_test/flutter_test.dart';

/// Usage: When I open {'Test Movie'}
///
/// Taps it: a card, an episode, whatever on the screen has that text.
Future<void> iOpen(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
