import 'package:flutter_test/flutter_test.dart';

/// Usage: And I tap {'Open folder'}
///
/// Whatever on the screen has that text.
Future<void> iTap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
