import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

import 'world.dart';

/// Usage: And the {'Continue watching'} row shows how much is watched
///
/// A progress bar on its card.
Future<void> theRowShowsHowMuchIsWatched(
  WidgetTester tester,
  String title,
) async {
  expect(
    find.descendant(of: row(title), matching: find.byKey(ItemCard.progressBar)),
    findsOneWidget,
  );
}
