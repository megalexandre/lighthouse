import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'world.dart';

/// Usage: And the lines of {'book-epub'} are at most {640} wide
Future<void> theLinesOfAreAtMostWide(
  WidgetTester tester,
  String itemId,
  num width,
) async {
  final sheet = tester.getSize(find.byKey(ReaderScreen.pages));
  final text = sheet.width - epubShown(tester, itemId).margins.horizontal;
  expect(text, lessThanOrEqualTo(width));
}
