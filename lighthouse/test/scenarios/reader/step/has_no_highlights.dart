import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'book-epub'} has no highlights
///
/// Kept on this device.
Future<void> hasNoHighlights(WidgetTester tester, String itemId) async {
  expect(app.books.highlightsOf[itemId] ?? const [], isEmpty);
}
