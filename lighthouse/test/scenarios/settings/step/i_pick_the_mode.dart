import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I pick the {'light'} mode
Future<void> iPickTheMode(WidgetTester tester, String mode) async {
  final choice = find.byKey(
    SettingsScreen.modeChoice(ThemeMode.values.byName(mode)),
  );
  await tester.ensureVisible(choice);
  await tester.tap(choice);
  await tester.pumpAndSettle();
}
