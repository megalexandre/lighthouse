import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: Then the card of {'Test Show'} has no play button
Future<void> theCardOfHasNoPlayButton(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  expect(find.byKey(ItemCard.playKeyFor(itemNamed(name).id)), findsNothing);
}
