import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the page sound is available
///
/// As it will be once the sounds are right (off in the app for now).
Future<void> thePageSoundIsAvailable(WidgetTester tester) async {
  app.pageSoundsAvailable = true;
}
