import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: And I turn the page with the right arrow key
Future<void> iTurnThePageWithTheRightArrowKey(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
  await tester.pumpAndSettle();
}
