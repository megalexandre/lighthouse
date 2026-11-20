import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: Given the bookmarks cannot be saved
///
/// The file on this device that keeps them cannot be written.
Future<void> theBookmarksCannotBeSaved(WidgetTester tester) async {
  app.books.failures['saveBookmarks'] = const NotReadable('bookmarks file');
}
