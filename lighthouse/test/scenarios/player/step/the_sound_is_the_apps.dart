import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the sound is the app's
///
/// The player before did not give up what the new one had.
Future<void> theSoundIsTheApps(WidgetTester tester) async {
  expect(app.audioFocus.owner, isNotNull);
}
