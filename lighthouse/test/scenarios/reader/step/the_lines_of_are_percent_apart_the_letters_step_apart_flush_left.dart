import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';

import 'world.dart';

/// Usage: Then the lines of {'book-epub'} are {115} percent apart, the letters {1} step apart, flush left
///
/// How the book is laid out, as those display settings say.
Future<void> theLinesOfArePercentApartTheLettersStepApartFlushLeft(
  WidgetTester tester,
  String itemId,
  num lines,
  num letters,
) async {
  final expected = ReaderPreferences(
    lineSpacing: lines.toInt(),
    letterSpacing: letters.toInt(),
    justify: false,
  ).typography;
  final type = epubShown(tester, itemId).typography;
  expect(type.lineHeight, expected.lineHeight);
  expect(type.letterSpacing, expected.letterSpacing);
  expect(type.justify, isFalse);
}
