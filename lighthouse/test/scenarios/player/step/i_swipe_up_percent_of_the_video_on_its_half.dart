import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I swipe up {30} percent of the video on its {'right'} half
///
/// From the middle of that half, a little below the video's middle (clear
/// of the big play button), by that share of the video's height.
Future<void> iSwipeUpPercentOfTheVideoOnItsHalf(
  WidgetTester tester,
  num percent,
  String side,
) async {
  final video = videoArea(tester);
  await tester.dragFrom(
    video.topLeft.translate(
      video.width * (side == 'left' ? 0.25 : 0.75),
      video.height * 0.6,
    ),
    Offset(0, -video.height * percent / 100),
  );
  await tester.pumpAndSettle();
}
