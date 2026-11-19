import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I play {'episode-1'}
///
/// From the item's page, its Play button.
Future<void> iPlay(WidgetTester tester, String itemId) async {
  await app.open(tester, Routes.item(itemId));
  await tester.tap(find.byKey(ItemScreen.playButton));
  await tester.pumpAndSettle();
  expect(find.byType(PlayerScreen), findsOneWidget);
}
