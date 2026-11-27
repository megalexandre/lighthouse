import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I write the note {'A good start'}
///
/// In the note's dialog, then Save.
Future<void> iWriteTheNote(WidgetTester tester, String note) async {
  await tester.enterText(find.byKey(ReaderScreen.noteField), note);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}
