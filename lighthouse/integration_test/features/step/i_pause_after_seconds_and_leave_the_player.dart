import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';
import '../../support/player.dart';
import 'world.dart' as world;

/// Usage: And I pause after {2} seconds and leave the player
///
/// Plays past [seconds], pauses, notes where, and goes back to the item.
Future<void> iPauseAfterSecondsAndLeaveThePlayer(
  WidgetTester tester,
  num seconds,
) async {
  final after = Duration(seconds: seconds.toInt());
  await waitUntil(
    tester,
    () => shownPosition(tester) > after,
    reason: 'playback to pass $after',
  );
  await tapOn(tester, find.byKey(PlayerScreen.playPauseButton));
  await waitFor(tester, find.byKey(PlayerScreen.centerPlayButton)); // Paused.
  world.pausedAt = shownPosition(tester);
  await tapOn(tester, find.byKey(PlayerScreen.backButton));
  await waitFor(tester, find.byKey(ItemScreen.resumeButton));
  expect(find.byType(PlayerScreen), findsNothing);
}
