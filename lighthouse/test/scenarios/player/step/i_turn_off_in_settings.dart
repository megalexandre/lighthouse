import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: When I turn off {'Swipe to seek'} in Settings
///
/// The switch with that title, on the Settings screen.
Future<void> iTurnOffInSettings(WidgetTester tester, String title) async {
  await app.open(tester, Routes.settings);
  final tile = find.widgetWithText(SwitchListTile, title);
  await tester.scrollUntilVisible(
    tile,
    200,
    scrollable: find
        .descendant(
          of: find.byType(SettingsScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  // To the top: at the bottom it may be under the phone's navigation bar.
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(tile).value, isTrue);
  await tester.tap(tile);
  await tester.pumpAndSettle();
  expect(tester.widget<SwitchListTile>(tile).value, isFalse);
}
