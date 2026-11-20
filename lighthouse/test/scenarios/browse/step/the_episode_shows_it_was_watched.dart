import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: Then the episode {'Episode 1'} shows it was watched
///
/// A check on its line of the season's page.
Future<void> theEpisodeShowsItWasWatched(
  WidgetTester tester,
  String name,
) async {
  expect(
    find.descendant(
      of: find.byKey(ItemScreen.episodeKey(itemNamed(name).id)),
      matching: find.byKey(ItemCard.watchedMark),
    ),
    findsOneWidget,
  );
}
