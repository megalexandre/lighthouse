import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';
import '../../support/player.dart';
import 'world.dart';

/// Usage: And Resume starts the movie there
///
/// Not at 0: at the saved place.
Future<void> resumeStartsTheMovieThere(WidgetTester tester) async {
  await tapOn(tester, find.byKey(ItemScreen.resumeButton));
  await waitFor(tester, find.byKey(PlayerScreen.positionText));
  final saved = Duration(seconds: savedAt.inSeconds);
  await waitUntil(
    tester,
    () => shownPosition(tester) >= saved,
    reason: 'resume at $saved',
    timeout: const Duration(seconds: 10),
  );
  expect(shownPosition(tester), lessThan(saved + const Duration(seconds: 4)));
}
