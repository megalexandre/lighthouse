import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the player shows {'Episode 2'}
///
/// Its title, among the controls (an episode: "S1:E2 · Episode 2").
Future<void> thePlayerShows(WidgetTester tester, String name) async {
  expect(
    find.descendant(
      of: find.byType(PlayerScreen),
      matching: find.textContaining(name),
    ),
    findsWidgets,
  );
}
