import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I swipe down {60} percent of the video on its {'right'} half
///
/// From the middle of that half, a little above the video's middle.
Future<void> iSwipeDownPercentOfTheVideoOnItsHalf(
  WidgetTester tester,
  num percent,
  String side,
) async {
  final video = videoArea(tester);
  await tester.dragFrom(
    video.topLeft.translate(
      video.width * (side == 'left' ? 0.25 : 0.75),
      video.height * 0.3,
    ),
    Offset(0, video.height * percent / 100),
  );
  await tester.pumpAndSettle();
}
