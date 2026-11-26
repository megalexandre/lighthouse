import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I swipe up from the bottom edge on the {'right'} half
///
/// From a few pixels above the bottom, where the system's gesture bar is.
Future<void> iSwipeUpFromTheBottomEdgeOnTheHalf(
  WidgetTester tester,
  String side,
) async {
  final video = videoArea(tester);
  await tester.dragFrom(
    Offset(
      video.left + video.width * (side == 'left' ? 0.25 : 0.75),
      video.bottom - 8,
    ),
    Offset(0, -video.height * 0.3),
  );
  await tester.pumpAndSettle();
}
