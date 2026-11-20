import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';

/// Usage: Then the panel is closed
Future<void> thePanelIsClosed(WidgetTester tester) async {
  expect(find.byKey(CardPopover.panel), findsNothing);
}
