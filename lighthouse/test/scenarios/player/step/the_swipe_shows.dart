import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_swipes.dart';

/// Usage: Then the swipe shows {'+1:00'}
Future<void> theSwipeShows(WidgetTester tester, String text) async {
  expect(
    find.descendant(
      of: find.byKey(PlayerSwipes.feedback),
      matching: find.text(text),
    ),
    findsOneWidget,
  );
}
