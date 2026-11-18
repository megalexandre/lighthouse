import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: Then {'Test Show S01E02'} is playing
///
/// Its name is in the player's title (an episode shows "S1:E2 · Name").
Future<void> isPlaying(WidgetTester tester, String name) async {
  await waitFor(
    tester,
    onScreen(PlayerScreen, find.textContaining(name)).first,
  );
  // The player before it may still be leaving.
  await settleRoute(tester);
}
