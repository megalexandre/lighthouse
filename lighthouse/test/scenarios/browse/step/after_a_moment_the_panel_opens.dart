import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';

/// Usage: Then after a moment the panel opens
///
/// Over the card, with the whole item.
Future<void> afterAMomentThePanelOpens(WidgetTester tester) async {
  await tester.pump(ItemCard.expandDelay);
  await tester.pumpAndSettle();
  expect(find.byKey(CardPopover.panel), findsOneWidget);
}
