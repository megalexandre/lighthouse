import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/user_configuration.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/theme/design_tokens.dart';
import 'package:jellyfin_flutter/core/theme/theme_catalog.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  /// Opens the dropdown of [field] and picks [option].
  Future<void> choose(WidgetTester tester, Key field, String option) async {
    await tester.tap(
      find.descendant(
        of: find.byKey(field),
        matching: find.byWidgetPredicate((w) => w is DropdownButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  /// Types [filter] into the language field [field] and picks [option].
  Future<void> chooseLanguage(
    WidgetTester tester,
    Key field,
    String filter,
    String option,
  ) async {
    final input = find.descendant(
      of: find.byKey(field),
      matching: find.byType(TextField),
    );
    await tester.tap(input);
    await tester.pumpAndSettle();
    await tester.enterText(input, filter);
    await tester.pumpAndSettle();
    // Filtered: of hundreds, only the matches are left in the open menu.
    // (Hidden copies of every entry exist too: the menu measures them.)
    final shown = find.byType(MenuItemButton).hitTestable().evaluate().length;
    expect(shown, lessThan(5), reason: 'the menu did not filter');
    await tester.tap(find.widgetWithText(MenuItemButton, option).hitTestable());
    await tester.pumpAndSettle();
  }

  testWidgets('opens from home and shows what is set', (tester) async {
    app.settings
      ..config = const UserConfiguration(
        audioLanguagePreference: 'por',
        subtitleMode: SubtitlePlaybackMode.always,
      )
      ..bitrate = 4000000;
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(HomeScreen.settingsButton));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('4 Mbps'), findsOneWidget);
    final audioField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(SettingsScreen.audioLanguageField),
        matching: find.byType(TextField),
      ),
    );
    expect(audioField.controller!.text, 'Portuguese');
    expect(find.text('Always'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('languages and subtitles go to the server', (tester) async {
    await app.open(tester, Routes.settings);
    await chooseLanguage(
      tester,
      SettingsScreen.audioLanguageField,
      'port',
      'Portuguese',
    );
    expect(app.settings.config.audioLanguagePreference, 'por');

    await choose(tester, SettingsScreen.subtitleModeField, 'Never');
    expect(app.settings.config.subtitleMode, SubtitlePlaybackMode.none);

    await chooseLanguage(
      tester,
      SettingsScreen.audioLanguageField,
      'file',
      "The file's default",
    );
    expect(app.settings.config.audioLanguagePreference, '');

    await tester.tap(find.byKey(SettingsScreen.autoplaySwitch));
    await tester.pumpAndSettle();
    expect(app.settings.config.enableNextEpisodeAutoPlay, isFalse);
  });

  testWidgets('quality is kept on this device', (tester) async {
    await app.open(tester, Routes.settings);
    await choose(tester, SettingsScreen.qualityField, '2 Mbps');
    expect(app.settings.bitrate, 2000000);
    await choose(tester, SettingsScreen.qualityField, 'Maximum');
    expect(app.settings.bitrate, isNull);
  });

  testWidgets('a failed save says so', (tester) async {
    app.settings.failures['update'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.settings);
    await chooseLanguage(
      tester,
      SettingsScreen.audioLanguageField,
      'port',
      'Portuguese',
    );
    expect(find.text(const ServerUnreachable(testUrl).message), findsOneWidget);
  });

  testWidgets('autoplay off: an episode ends, the player closes', (
    tester,
  ) async {
    app.settings.config = const UserConfiguration(
      enableNextEpisodeAutoPlay: false,
    );
    // Straight to the episode: the settings screen was never opened.
    await app.open(tester, Routes.item(TestItems.episodes.first.id));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
    app.engine.finish();
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
    expect(app.engines, hasLength(1));
  });

  group('appearance', () {
    final lanterna = File('assets/themes/lanterna.json').readAsStringSync();

    ThemeData shownTheme(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(SettingsScreen)));

    Color accent(String mode) =>
        DesignTokens.parse(lanterna).color('accent', mode);

    /// Prime's accent: the default theme.
    Color primeAccent(String mode) => DesignTokens.parse(
      File('assets/themes/prime.json').readAsStringSync(),
      fallback: DesignTokens.parse(lanterna),
    ).color('accent', mode);

    testWidgets('Prime in dark by default; light picked: applied and '
        'kept', (tester) async {
      app.appFiles.values.remove('appearance'); // Nothing chosen yet.
      await app.open(tester, Routes.settings);
      expect(shownTheme(tester).colorScheme.primary, primeAccent('dark'));
      await tester.ensureVisible(
        find.byKey(SettingsScreen.modeChoice(ThemeMode.light)),
      );
      await tester.tap(find.byKey(SettingsScreen.modeChoice(ThemeMode.light)));
      await tester.pumpAndSettle();
      expect(shownTheme(tester).brightness, Brightness.light);
      expect(shownTheme(tester).colorScheme.primary, primeAccent('light'));
      expect(app.appFiles.values['appearance'], contains('"light"'));

      // Lanterna is still there to pick.
      await choose(tester, SettingsScreen.themeField, 'Lanterna');
      expect(shownTheme(tester).colorScheme.primary, accent('light'));
      expect(app.appFiles.values['appearance'], contains('lanterna'));
    });

    testWidgets('a file from before (the default of the time stored with a '
        'mode change) follows today\'s default, mode kept; a mode change '
        'does not fix the theme', (tester) async {
      app.appFiles.values['appearance'] =
          '{"theme":"builtin:lanterna.json","mode":"light"}';
      await app.open(tester, Routes.settings);
      expect(shownTheme(tester).colorScheme.primary, primeAccent('light'));

      await tester.ensureVisible(
        find.byKey(SettingsScreen.modeChoice(ThemeMode.dark)),
      );
      await tester.tap(find.byKey(SettingsScreen.modeChoice(ThemeMode.dark)));
      await tester.pumpAndSettle();
      expect(app.appFiles.values['appearance'], isNot(contains('Theme')));
      expect(app.appFiles.values['appearance'], contains('"dark"'));
    });

    testWidgets('a theme from the user\'s folder: listed, picked; one '
        'that cannot be read is reported', (tester) async {
      app.userThemes.files
        ..['mine.json'] = lanterna
            .replaceFirst('"name": "Lanterna"', '"name": "Mine"')
            .replaceAll('#00a4dc', '#ff8800')
        ..['broken.json'] = '{';
      await app.open(tester, Routes.settings);
      await tester.ensureVisible(find.byKey(SettingsScreen.themeField));
      await choose(tester, SettingsScreen.themeField, 'Mine (your folder)');
      expect(shownTheme(tester).colorScheme.primary, const Color(0xFFFF8800));
      expect(app.appFiles.values['appearance'], contains('user:mine.json'));

      await tester.ensureVisible(find.byKey(SettingsScreen.themeIssues));
      expect(find.text('1 theme issue'), findsOneWidget);
      await tester.tap(find.byKey(SettingsScreen.themeIssues));
      await tester.pumpAndSettle();
      expect(find.textContaining('broken.json: not used'), findsOneWidget);
    });

    testWidgets('saving the theme file changes the app as it runs', (
      tester,
    ) async {
      app.userThemes.files['mine.json'] = lanterna;
      app.appFiles.values['appearance'] = '{"chosenTheme":"user:mine.json"}';
      await app.open(tester, Routes.settings);
      expect(shownTheme(tester).colorScheme.primary, accent('dark'));
      app.userThemes.files['mine.json'] = lanterna.replaceAll(
        '#00a4dc',
        '#22cc66',
      );
      app.userThemes.changed();
      await tester.pump(ThemeCatalogController.settle);
      await tester.pumpAndSettle();
      expect(shownTheme(tester).colorScheme.primary, const Color(0xFF22CC66));
    });

    testWidgets('the player stays dark in light mode', (tester) async {
      app.appFiles.values['appearance'] = '{"mode":"light"}';
      await app.open(tester, Routes.item(TestItems.episodes.first.id));
      expect(
        Theme.of(tester.element(find.byType(ItemScreen))).brightness,
        Brightness.light,
      );
      await tester.tap(find.byKey(ItemScreen.playButton));
      await tester.pumpAndSettle();
      final player = Theme.of(tester.element(find.byKey(PlayerScreen.seekBar)));
      expect(player.brightness, Brightness.dark);
    });
  });
}
