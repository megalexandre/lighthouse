import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';

const _buttons = {
  'play': CardPopover.playButton,
  'watched': CardPopover.watchedButton,
  'details': CardPopover.infoButton,
};

/// Usage: When I tap {'watched'} in the panel
Future<void> iTapInThePanel(WidgetTester tester, String button) async {
  await tester.tap(find.byKey(_buttons[button]!));
  await tester.pumpAndSettle();
}
