import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I open the bookmarks
///
/// Beside the contents.
Future<void> iOpenTheBookmarks(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.contentsButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ReaderScreen.bookmarksTab));
  await tester.pumpAndSettle();
}
