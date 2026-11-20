import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the player is still open
Future<void> thePlayerIsStillOpen(WidgetTester tester) async {
  expect(find.byType(PlayerScreen), findsOneWidget);
}
