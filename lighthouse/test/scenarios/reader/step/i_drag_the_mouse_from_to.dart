import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I drag the mouse from {'first'} to {'novel'}
///
/// From the start of the first word to the end of the second, as a
/// mouse selects text.
Future<void> iDragTheMouseFromTo(
  WidgetTester tester,
  String from,
  String to,
) async {
  final start = wordOnPage(tester, from).centerLeft + const Offset(1, 0);
  final end = wordOnPage(tester, to).centerRight - const Offset(1, 0);
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.mouse,
  );
  for (var i = 1; i <= 8; i++) {
    await gesture.moveTo(Offset.lerp(start, end, i / 8)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}
