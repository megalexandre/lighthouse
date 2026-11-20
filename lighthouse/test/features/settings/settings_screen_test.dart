import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// What a user does in Settings is in test/scenarios/settings/. Here: how a
// stored file of an older shape is read, which no user drives.
void main() {
  testWidgets('a file from before (the default of the time stored with a '
      'mode change) follows today\'s default, mode kept; a mode change '
      'does not fix the theme', (tester) async {
    final app = TestApp();
    final primeLight = DesignTokens.parse(
      File('assets/themes/prime.json').readAsStringSync(),
      fallback: DesignTokens.parse(
        File('assets/themes/lanterna.json').readAsStringSync(),
      ),
    ).color('accent', 'light');
    app.appFiles.values['appearance'] =
        '{"theme":"builtin:lanterna.json","mode":"light"}';
    await app.open(tester, Routes.settings);
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).colorScheme.primary,
      primeLight,
    );

    final dark = find.byKey(SettingsScreen.modeChoice(ThemeMode.dark));
    await tester.ensureVisible(dark);
    await tester.tap(dark);
    await tester.pumpAndSettle();
    expect(app.appFiles.values['appearance'], isNot(contains('Theme')));
    expect(app.appFiles.values['appearance'], contains('"dark"'));
  });
}
