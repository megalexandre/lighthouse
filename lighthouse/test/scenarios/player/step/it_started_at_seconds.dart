import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And it started at {64} seconds
///
/// The stream was asked for, and opened, from there.
Future<void> itStartedAtSeconds(WidgetTester tester, num seconds) async {
  final start = Duration(seconds: seconds.toInt());
  expect(app.playback.prepareCalls.last.$1, start);
  expect(app.engine.openedStart, start);
}
