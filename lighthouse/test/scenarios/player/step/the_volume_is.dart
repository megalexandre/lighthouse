import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the volume is {95}
///
/// And the sound is on.
Future<void> theVolumeIs(WidgetTester tester, num volume) async {
  expect((app.engine.volume, app.engine.muted), (volume, false));
}
