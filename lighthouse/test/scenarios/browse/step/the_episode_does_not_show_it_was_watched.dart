import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: And the episode {'Episode 2'} does not show it was watched
Future<void> theEpisodeDoesNotShowItWasWatched(
  WidgetTester tester,
  String name,
) async {
  expect(
    find.descendant(
      of: find.byKey(ItemScreen.episodeKey(itemNamed(name).id)),
      matching: find.byKey(ItemCard.watchedMark),
    ),
    findsNothing,
  );
}
