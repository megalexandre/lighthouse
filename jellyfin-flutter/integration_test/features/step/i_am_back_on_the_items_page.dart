import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: Then I am back on the item's page
///
/// The player closed by itself.
Future<void> iAmBackOnTheItemsPage(WidgetTester tester) async {
  await waitUntil(
    tester,
    () => find.byType(PlayerScreen).evaluate().isEmpty,
    reason: 'the player to close at the end',
  );
  await waitFor(tester, find.byKey(ItemScreen.playButton));
  expect(find.byKey(ItemScreen.resumeButton), findsNothing);
}
