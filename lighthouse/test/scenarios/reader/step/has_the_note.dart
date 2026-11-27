import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'test'} has the note {'A good start'}
Future<void> hasTheNote(WidgetTester tester, String text, String note) async {
  final notes = [
    for (final highlights in app.books.highlightsOf.values)
      for (final h in highlights)
        if (h.text == text) h.note,
  ];
  expect(notes, [note]);
}
