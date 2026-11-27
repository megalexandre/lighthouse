import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/data/highlight.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I highlight it {'red'}
///
/// The colour's dot in the menu over the selection (or a highlight).
Future<void> iHighlightIt(WidgetTester tester, String color) async {
  await tester.tap(
    find.byKey(
      ReaderScreen.highlightColor(HighlightColor.values.byName(color)),
    ),
  );
  await tester.pumpAndSettle();
}
