import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: Then the player floats
///
/// The window floats, and only the picture is in it: none of the controls.
Future<void> thePlayerFloats(WidgetTester tester) async {
  expect(app.floating.floating, isTrue);
  expect(find.byType(PlayerScreen), findsOneWidget);
  expect(find.byKey(PlayerScreen.seekBar), findsNothing);
}
