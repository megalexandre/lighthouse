import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I press {'Space'}
///
/// One of [keys], or Ctrl+ one of them.
Future<void> iPress(WidgetTester tester, String key) async {
  if (key.startsWith('Ctrl+')) {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(keys[key.substring(5)]!);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  } else {
    await tester.sendKeyEvent(keys[key]!);
  }
  await tester.pumpAndSettle();
}
