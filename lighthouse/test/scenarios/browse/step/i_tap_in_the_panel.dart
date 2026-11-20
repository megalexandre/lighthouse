import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';

const _parts = {
  'play': CardPopover.playButton,
  'watched': CardPopover.watchedButton,
  'details': CardPopover.infoButton,
  'picture': CardPopover.picture,
  'title': CardPopover.title,
};

/// Usage: When I tap {'watched'} in the panel
///
/// One of its buttons, its 'picture', or its 'title'.
Future<void> iTapInThePanel(WidgetTester tester, String part) async {
  await tester.tap(find.byKey(_parts[part]!));
  await tester.pumpAndSettle();
}
