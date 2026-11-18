import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: When I choose {'Portuguese'} as the audio language in Settings
///
/// Types its start into the field, as a user would (the menu filters on
/// it), and picks it from the server's list of languages.
Future<void> iChooseAsTheAudioLanguageInSettings(
  WidgetTester tester,
  String language,
) async {
  await waitFor(tester, find.byKey(HomeScreen.settingsButton));
  await tapOn(tester, find.byKey(HomeScreen.settingsButton));
  final field = find.descendant(
    of: find.byKey(SettingsScreen.audioLanguageField),
    matching: find.byType(TextField),
  );
  await waitFor(tester, field);
  await typeInto(tester, field, language.substring(0, 6).toLowerCase());
  // The open menu's entry: the menu also keeps hidden copies of every
  // entry, to measure its width.
  final entry = find.widgetWithText(MenuItemButton, language).hitTestable();
  await waitFor(tester, entry);
  await tapOn(tester, entry);
  await waitUntil(
    tester,
    () => tester.widget<TextField>(field).controller?.text == language,
    reason: 'the field to show $language',
  );
}
