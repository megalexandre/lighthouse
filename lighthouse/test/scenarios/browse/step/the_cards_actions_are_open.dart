import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_actions.dart';

/// Usage: Then the card's actions are open
///
/// The sheet a long press opens on touch.
Future<void> theCardsActionsAreOpen(WidgetTester tester) async {
  expect(find.byType(CardActions), findsOneWidget);
}
