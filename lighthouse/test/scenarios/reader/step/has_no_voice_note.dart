import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then {'first'} has no voice note
Future<void> hasNoVoiceNote(WidgetTester tester, String text) async {
  final voices = [
    for (final highlights in app.books.highlightsOf.values)
      for (final h in highlights)
        if (h.text == text && h.hasVoice) h.voice,
  ];
  expect(voices, isEmpty);
}
