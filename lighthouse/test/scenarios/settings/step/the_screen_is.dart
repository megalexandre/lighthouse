import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the screen is {'light'}
///
/// The item's page.
Future<void> theScreenIs(WidgetTester tester, String mode) async {
  expect(
    Theme.of(tester.element(find.byType(ItemScreen))).brightness,
    Brightness.values.byName(mode),
  );
}
