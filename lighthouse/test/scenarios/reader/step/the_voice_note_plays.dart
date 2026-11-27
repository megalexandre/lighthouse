import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the voice note {'voice-1.wav'} plays
Future<void> theVoiceNotePlays(WidgetTester tester, String file) async {
  expect(app.notePlayer.playing.value, '${app.voiceNotes.path}/$file');
}
