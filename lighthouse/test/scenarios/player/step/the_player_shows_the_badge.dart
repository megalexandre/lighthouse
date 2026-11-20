import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the player shows the badge {'4K'}
Future<void> thePlayerShowsTheBadge(WidgetTester tester, String badge) async {
  expect(
    find.descendant(of: find.byType(PlayerScreen), matching: find.text(badge)),
    findsOneWidget,
  );
}
