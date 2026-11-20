import 'package:flutter_test/flutter_test.dart';

/// Usage: When I tap {'Chapter Three'}
///
/// Whatever on the screen has that text.
Future<void> iTap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
