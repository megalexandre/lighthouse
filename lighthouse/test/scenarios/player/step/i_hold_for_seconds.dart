import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I hold {'Enter'} for {2} seconds
///
/// One of [keys], down that long, then up.
Future<void> iHoldForSeconds(
  WidgetTester tester,
  String key,
  num seconds,
) async {
  const platform = 'android';
  await tester.sendKeyDownEvent(keys[key]!, platform: platform);
  await holdFor(tester, seconds);
  await tester.sendKeyUpEvent(keys[key]!, platform: platform);
  await tester.pumpAndSettle();
}
