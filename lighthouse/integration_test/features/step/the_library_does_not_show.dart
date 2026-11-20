import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

/// Usage: And the library does not show {'Test Movie (2020)'}
Future<void> theLibraryDoesNotShow(WidgetTester tester, String name) async {
  expect(
    find.descendant(of: find.byType(LibraryScreen), matching: find.text(name)),
    findsNothing,
  );
}
