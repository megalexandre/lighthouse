import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the player is open
Future<void> thePlayerIsOpen(WidgetTester tester) async {
  expect(find.byType(PlayerScreen), findsOneWidget);
}
