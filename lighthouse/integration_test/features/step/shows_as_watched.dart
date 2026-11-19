import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: Then {'Test Movie (2020)'} shows as watched
///
/// Its card in a library, or its row in a season, has the watched check,
/// without leaving the screen: it updates by itself.
Future<void> showsAsWatched(WidgetTester tester, String name) async {
  bool isItem(Widget w) => switch (w) {
    ItemCard() => true,
    Widget(key: ValueKey<String>(:final value)) => value.startsWith('episode.'),
    _ => false,
  };
  await waitFor(
    tester,
    find.descendant(
      of: find.ancestor(
        of: find.textContaining(name),
        matching: find.byWidgetPredicate(isItem),
      ),
      matching: find.byKey(ItemCard.watchedMark),
    ),
  );
}
