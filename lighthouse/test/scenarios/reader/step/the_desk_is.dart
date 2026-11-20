import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the desk is {'dark'}
///
/// The colour around the page, of that reader theme.
Future<void> theDeskIs(WidgetTester tester, String theme) async {
  final scaffold = tester.widget<Scaffold>(
    find.descendant(
      of: find.byType(ReaderScreen),
      matching: find.byType(Scaffold),
    ),
  );
  expect(scaffold.backgroundColor, ReaderTheme.values.byName(theme).desk);
}
