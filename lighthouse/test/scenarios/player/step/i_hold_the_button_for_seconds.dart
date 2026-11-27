import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I hold the {'unlock'} button for {2} seconds
///
/// One of [buttons], a finger kept on it that long.
Future<void> iHoldTheButtonForSeconds(
  WidgetTester tester,
  String name,
  num seconds,
) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(buttons[name]!)),
  );
  await holdFor(tester, seconds);
  await gesture.up();
  await tester.pumpAndSettle();
}
