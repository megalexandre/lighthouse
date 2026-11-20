import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then home is {'light'}
Future<void> homeIs(WidgetTester tester, String mode) async {
  expect(
    Theme.of(tester.element(find.byType(HomeScreen))).brightness,
    Brightness.values.byName(mode),
  );
}
