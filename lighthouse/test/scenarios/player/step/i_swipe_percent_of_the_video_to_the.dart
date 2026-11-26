import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I swipe {50} percent of the video to the {'left'}
///
/// By that share of the video's width, then the finger lifts.
Future<void> iSwipePercentOfTheVideoToThe(
  WidgetTester tester,
  num percent,
  String side,
) async {
  final (start, by) = sideways(tester, percent, side);
  await tester.dragFrom(start, by);
  await tester.pumpAndSettle();
}
