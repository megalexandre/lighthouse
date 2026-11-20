import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: And the card of {'HEVC Movie'} shows how far it got
///
/// A progress bar along its picture.
Future<void> theCardOfShowsHowFarItGot(WidgetTester tester, String name) async {
  expect(
    find.descendant(
      of: cardOf(name),
      matching: find.byKey(ItemCard.progressBar),
    ),
    findsOneWidget,
  );
}
