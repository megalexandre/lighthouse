import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I pick {'3. Episode 3'} in the panel
///
/// A row (an episode, a chapter) or a season, by its text.
Future<void> iPickInThePanel(WidgetTester tester, String text) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(PlayerScreen.sidePanel),
      matching: find.text(text),
    ),
  );
  await tester.pumpAndSettle();
}
