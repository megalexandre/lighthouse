import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: And I go to the last page
///
/// The End key.
Future<void> iGoToTheLastPage(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.end);
  await tester.pumpAndSettle();
}
