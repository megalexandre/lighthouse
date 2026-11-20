import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';

/// Usage: And the panel shows {'A movie made for tests.'}
Future<void> thePanelShows(WidgetTester tester, String text) async {
  expect(
    find.descendant(
      of: find.byKey(CardPopover.panel),
      matching: find.text(text),
    ),
    findsOneWidget,
  );
}
