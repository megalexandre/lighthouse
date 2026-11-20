import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

/// Usage: Then after half a moment no panel is open
///
/// The mouse only passing over a card opens nothing.
Future<void> afterHalfAMomentNoPanelIsOpen(WidgetTester tester) async {
  await tester.pump(ItemCard.expandDelay ~/ 2);
  expect(find.byKey(CardPopover.panel), findsNothing);
}
