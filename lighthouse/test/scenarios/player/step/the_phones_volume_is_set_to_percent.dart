import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the phone's volume is set to {20} percent
///
/// Its media volume, the one its keys change.
Future<void> thePhonesVolumeIsSetToPercent(
  WidgetTester tester,
  num percent,
) async {
  app.levels.volumeLevel = percent / 100;
}
