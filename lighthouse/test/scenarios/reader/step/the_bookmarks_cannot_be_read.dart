import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: Given the bookmarks cannot be read
///
/// The file on this device that keeps them is unreadable.
Future<void> theBookmarksCannotBeRead(WidgetTester tester) async {
  app.books.failures['bookmarks'] = const NotReadable('bookmarks file');
}
