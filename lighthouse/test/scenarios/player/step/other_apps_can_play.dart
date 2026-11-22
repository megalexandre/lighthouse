import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And other apps can play
///
/// The app let the audio focus go.
Future<void> otherAppsCanPlay(WidgetTester tester) async {
  expect(app.audioFocus.owner, isNull);
}
