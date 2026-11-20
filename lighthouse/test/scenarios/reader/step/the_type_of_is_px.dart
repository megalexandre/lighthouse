import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the type of {'book-epub'} is {22} px
///
/// What the book is laid out with.
Future<void> theTypeOfIsPx(WidgetTester tester, String itemId, num size) async {
  expect(epubShown(tester, itemId).typography.fontSize, size);
}
