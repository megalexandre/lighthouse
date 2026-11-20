import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the type of {'book-epub'} is {'Literata'}
///
/// The font the book is laid out in.
Future<void> theTypeOfIs(
  WidgetTester tester,
  String itemId,
  String font,
) async {
  expect(epubShown(tester, itemId).typography.fontFamily, font);
}
