import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I press {'Space'}
///
/// One of [keys].
Future<void> iPress(WidgetTester tester, String key) async {
  await tester.sendKeyEvent(keys[key]!);
  await tester.pumpAndSettle();
}
