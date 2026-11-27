import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then no voice note plays
Future<void> noVoiceNotePlays(WidgetTester tester) async {
  expect(app.notePlayer.playing.value, isNull);
}
