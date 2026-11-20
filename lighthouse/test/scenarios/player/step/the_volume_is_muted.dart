import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the volume is {90}, muted
Future<void> theVolumeIsMuted(WidgetTester tester, num volume) async {
  expect((app.engine.volume, app.engine.muted), (volume, true));
}
