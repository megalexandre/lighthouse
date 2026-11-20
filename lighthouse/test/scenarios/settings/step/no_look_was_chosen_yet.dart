import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given no look was chosen yet
///
/// No theme, no mode stored on this device.
Future<void> noLookWasChosenYet(WidgetTester tester) async {
  app.appFiles.values.remove('appearance');
}
