import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I press {'Space'}
///
/// One of [keys], or Ctrl+ one of them.
///
/// Sent as Android's key events: flutter_test's Linux key map has no media
/// keys (the app reads logical keys, the same on both).
Future<void> iPress(WidgetTester tester, String key) async {
  const platform = 'android';
  if (key.startsWith('Ctrl+')) {
    await tester.sendKeyDownEvent(
      LogicalKeyboardKey.controlLeft,
      platform: platform,
    );
    await tester.sendKeyEvent(keys[key.substring(5)]!, platform: platform);
    await tester.sendKeyUpEvent(
      LogicalKeyboardKey.controlLeft,
      platform: platform,
    );
  } else {
    await tester.sendKeyEvent(keys[key]!, platform: platform);
  }
  await tester.pumpAndSettle();
}
