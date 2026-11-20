import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And the paper is {'dark'}
///
/// The page's colour, of that reader theme.
Future<void> thePaperIs(WidgetTester tester, String theme) async {
  final paper = ReaderTheme.values.byName(theme).colors.paper;
  expect(
    find.descendant(
      of: find.byKey(ReaderScreen.pages),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == paper,
      ),
    ),
    findsOneWidget,
  );
}
