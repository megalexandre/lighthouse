import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _keys = {
  'Left': LogicalKeyboardKey.arrowLeft,
  'Right': LogicalKeyboardKey.arrowRight,
  'Home': LogicalKeyboardKey.home,
  'End': LogicalKeyboardKey.end,
};

/// Usage: When I press {'End'}
Future<void> iPress(WidgetTester tester, String key) async {
  await tester.sendKeyEvent(_keys[key]!);
  await tester.pumpAndSettle();
}
