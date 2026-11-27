import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/lock.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I hold the padlock
///
/// The mouse's button down on it a little longer than it takes (real
/// time: the ring's animation runs on the clock).
Future<void> iHoldThePadlock(WidgetTester tester) async {
  await waitFor(tester, find.byKey(PlayerScreen.unlockButton));
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(PlayerScreen.unlockButton)),
  );
  final until = DateTime.now().add(
    UnlockButton.hold + const Duration(milliseconds: 500),
  );
  while (DateTime.now().isBefore(until)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await gesture.up();
  await tester.pump();
}
