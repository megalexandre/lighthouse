import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the phone's volume keys work
Future<void> thePhonesVolumeKeysWork(WidgetTester tester) async {
  expect(app.levels.volumeKeysHeld, isFalse);
}
