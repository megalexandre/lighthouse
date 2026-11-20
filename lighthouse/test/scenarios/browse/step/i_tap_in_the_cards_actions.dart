import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_actions.dart';

const _buttons = {
  'play': CardActions.mainButton,
  'watched': CardActions.watchedButton,
  'details': CardActions.detailsButton,
};

/// Usage: When I tap {'watched'} in the card's actions
///
/// 'play' (the main action: play, resume, read...), 'watched', 'details'.
Future<void> iTapInTheCardsActions(WidgetTester tester, String button) async {
  await tester.tap(find.byKey(_buttons[button]!));
  await tester.pumpAndSettle();
}
