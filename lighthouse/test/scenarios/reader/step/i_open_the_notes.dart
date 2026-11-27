import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I open the notes
///
/// Beside the contents and the bookmarks.
Future<void> iOpenTheNotes(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.contentsButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ReaderScreen.notesTab));
  await tester.pumpAndSettle();
}
