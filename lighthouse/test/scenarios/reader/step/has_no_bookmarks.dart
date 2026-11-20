import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'book-epub'} has no bookmarks
///
/// Kept on this device.
Future<void> hasNoBookmarks(WidgetTester tester, String itemId) async {
  expect(app.books.bookmarksOf[itemId], isEmpty);
}
