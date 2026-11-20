import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: When I tap the play button of {'Test Movie'}
///
/// On its card.
Future<void> iTapThePlayButtonOf(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(ItemCard.playKeyFor(itemNamed(name).id)));
  await tester.pumpAndSettle();
}
