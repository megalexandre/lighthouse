import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then {'first'} is highlighted {'red'}
///
/// As kept on this device (of any book).
Future<void> isHighlighted(
  WidgetTester tester,
  String text,
  String color,
) async {
  final kept = [
    for (final highlights in app.books.highlightsOf.values)
      for (final h in highlights) (h.text, h.color.name),
  ];
  expect(kept, [(text, color)]);
}
