import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I tap the {'play/pause'} button
///
/// One of [buttons], on an item's page or in the player.
Future<void> iTapTheButton(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(buttons[name]!));
  await tester.pumpAndSettle();
}
