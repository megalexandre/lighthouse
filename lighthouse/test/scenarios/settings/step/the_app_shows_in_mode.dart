import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: Then the app shows {'Prime'} in {'dark'} mode
///
/// Its accent for that mode, on light or dark.
Future<void> theAppShowsInMode(
  WidgetTester tester,
  String theme,
  String mode,
) async {
  final shown = shownTheme(tester);
  expect(
    shown.brightness,
    mode == 'light' ? Brightness.light : Brightness.dark,
  );
  expect(shown.colorScheme.primary, accentOf(theme, mode));
}
