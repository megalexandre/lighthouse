import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is told the volume is {100}, muted
Future<void> theServerIsToldTheVolumeIsMuted(
  WidgetTester tester,
  num volume,
) async {
  expect(lastReport().isMuted, isTrue);
  expect(lastReport().volumeLevel, volume);
}
