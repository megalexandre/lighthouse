import 'package:flutter_test/flutter_test.dart';

import 'world.dart' as world;

/// Usage: When I put a finger down and slide it {50} percent of the video to the {'right'}
///
/// By that share of the video's width, keeping the finger down
/// ([world.finger]) until `I lift the finger`.
Future<void> iPutAFingerDownAndSlideItPercentOfTheVideoToThe(
  WidgetTester tester,
  num percent,
  String side,
) async {
  final (start, by) = world.sideways(tester, percent, side);
  final finger = world.finger = await tester.startGesture(start);
  // In steps, as a finger moves: the first ones decide the way.
  for (var i = 1; i <= 10; i++) {
    await finger.moveBy(by / 10);
    await tester.pump();
  }
}
