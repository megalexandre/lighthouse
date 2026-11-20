import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_actions.dart';

/// Usage: Then the card's actions are closed
Future<void> theCardsActionsAreClosed(WidgetTester tester) async {
  expect(find.byType(CardActions), findsNothing);
}
