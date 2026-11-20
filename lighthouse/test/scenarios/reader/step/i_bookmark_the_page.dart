import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I bookmark the page
Future<void> iBookmarkThePage(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.bookmarkButton));
  await tester.pumpAndSettle();
}
