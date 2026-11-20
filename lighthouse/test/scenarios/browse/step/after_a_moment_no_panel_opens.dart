import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

/// Usage: Then after a moment no panel opens
Future<void> afterAMomentNoPanelOpens(WidgetTester tester) async {
  await tester.pump(ItemCard.expandDelay * 2);
  await tester.pumpAndSettle();
  expect(find.byKey(CardPopover.panel), findsNothing);
}
