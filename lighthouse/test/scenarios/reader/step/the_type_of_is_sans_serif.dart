import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the type of {'book-epub'} is sans serif
Future<void> theTypeOfIsSansSerif(WidgetTester tester, String itemId) async {
  expect(epubShown(tester, itemId).typography.fontFamily, 'sans-serif');
}
