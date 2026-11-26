import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the phone's volume is {70} percent
Future<void> thePhonesVolumeIsPercent(WidgetTester tester, num percent) async {
  expect(app.levels.volumeLevel * 100, moreOrLessEquals(percent.toDouble()));
}
