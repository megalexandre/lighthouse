import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the phone's volume keys do nothing
Future<void> thePhonesVolumeKeysDoNothing(WidgetTester tester) async {
  expect(app.levels.volumeKeysHeld, isTrue);
}
