import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I move the mouse away
///
/// To a corner with nothing under it.
Future<void> iMoveTheMouseAway(WidgetTester tester) async {
  await mouse!.moveTo(const Offset(1500, 1100));
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pumpAndSettle();
}
