import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: Then the player's controls are back
Future<void> thePlayersControlsAreBack(WidgetTester tester) async {
  await waitUntil(
    tester,
    () =>
        find.byKey(PlayerScreen.unlockButton).evaluate().isEmpty &&
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity ==
            1,
    reason: 'the controls showing again',
  );
}
