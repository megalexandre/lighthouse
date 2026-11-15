import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/user_configuration.dart';
import 'package:jellyfin_flutter/core/failure.dart';
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
}
