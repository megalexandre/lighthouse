import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told {'movie-1'} stopped at {42} seconds
///
/// The one stop it was told about.
Future<void> theServerIsToldStoppedAtSeconds(
  WidgetTester tester,
  String itemId,
  num seconds,
) async {
  final stop = app.playback.stopped.single;
  expect(stop.itemId, itemId);
  expect(stop.positionTicks, seconds * ticksPerSecond);
}
