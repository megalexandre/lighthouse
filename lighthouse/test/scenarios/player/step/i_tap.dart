import 'package:flutter_test/flutter_test.dart';

/// Usage: And I tap {'Track 2'}
///
/// Whatever on the screen has that text.
Future<void> iTap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
