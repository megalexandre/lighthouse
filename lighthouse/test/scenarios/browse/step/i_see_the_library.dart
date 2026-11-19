import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I see the {'Movies'} library
///
/// Its grid, under its name in the top bar.
Future<void> iSeeTheLibrary(WidgetTester tester, String name) async {
  expect(find.byType(LibraryScreen), findsOneWidget);
  expect(
    find.descendant(of: find.byType(AppBar), matching: find.text(name)),
    findsOneWidget,
  );
}
