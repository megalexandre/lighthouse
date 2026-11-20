import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart' as world;

/// Usage: When I slide a finger along the seek bar
///
/// From its middle, and keeps the finger down ([world.finger]) until
/// `I lift the finger`.
Future<void> iSlideAFingerAlongTheSeekBar(WidgetTester tester) async {
  final finger = world.finger = await tester.startGesture(
    tester.getCenter(find.byKey(PlayerScreen.seekBar)),
  );
  // The first move starts the drag, the next ones show where it is.
  await finger.moveBy(const Offset(40, 0));
  await finger.moveBy(const Offset(20, 0));
  await tester.pump();
}
