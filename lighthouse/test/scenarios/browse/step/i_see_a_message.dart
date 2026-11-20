import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I see a message {'Cannot reach ...'}
///
/// A snack bar at the bottom of the screen.
Future<void> iSeeAMessage(WidgetTester tester, String message) async {
  expect(
    find.descendant(of: find.byType(SnackBar), matching: find.text(message)),
    findsOneWidget,
  );
}
