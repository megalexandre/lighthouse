import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'first'} has a voice note of {7} seconds
///
/// As kept on this device.
Future<void> hasAVoiceNoteOfSeconds(
  WidgetTester tester,
  String text,
  int seconds,
) async {
  final voices = [
    for (final highlights in app.books.highlightsOf.values)
      for (final h in highlights)
        if (h.text == text) h.voiceLength,
  ];
  expect(voices, [Duration(seconds: seconds)]);
}
