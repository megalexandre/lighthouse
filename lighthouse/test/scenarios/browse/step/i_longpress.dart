import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I long-press {'Test Movie'}
///
/// Its card, with a finger.
Future<void> iLongpress(WidgetTester tester, String name) async {
  await tester.longPress(cardOf(name));
  await tester.pumpAndSettle();
}
