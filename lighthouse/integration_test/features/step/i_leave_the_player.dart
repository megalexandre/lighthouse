import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I leave the player
///
/// Esc, whether the controls are up or not: back to the item's page.
Future<void> iLeaveThePlayer(WidgetTester tester) async {
  await pressKey(tester, LogicalKeyboardKey.escape);
  await waitUntil(
    tester,
    () => find.byType(PlayerScreen).evaluate().isEmpty,
    reason: 'the player to close',
  );
  await settleRoute(tester);
  await waitFor(tester, find.byType(ItemScreen));
}
