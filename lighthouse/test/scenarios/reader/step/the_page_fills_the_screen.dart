import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: Then the page fills the screen
///
/// Its sheet, edge to edge: no desk around it.
Future<void> thePageFillsTheScreen(WidgetTester tester) async {
  expect(
    tester.getRect(find.byKey(ReaderScreen.pages)),
    Offset.zero & tester.getSize(find.byType(ReaderScreen)),
  );
}
