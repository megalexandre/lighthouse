import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: Then the player is back in its window
///
/// It floats no more, and its controls are back.
Future<void> thePlayerIsBackInItsWindow(WidgetTester tester) async {
  expect(app.floating.floating, isFalse);
  expect(find.byKey(PlayerScreen.seekBar), findsOneWidget);
  expect(find.byKey(PlayerScreen.floatingWindow), findsNothing);
}
