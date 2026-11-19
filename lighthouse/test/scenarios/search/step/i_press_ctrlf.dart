import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: When I press Ctrl+F
Future<void> iPressCtrlf(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}
