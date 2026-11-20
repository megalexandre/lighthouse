// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/my_audio_language_on_the_server_is.dart';
import './step/my_subtitles_on_the_server_are.dart';
import './step/my_quality_limit_is_mbps.dart';
import './step/i_open_settings_from_home.dart';
import './step/i_see.dart';
import './step/the_audio_language_reads.dart';
import './step/i_open_settings.dart';
import './step/i_type_in_the_language_and_pick.dart';
import './step/the_server_keeps_my_language_as.dart';
import './step/i_pick_in_the_setting.dart';
import './step/the_server_keeps_my_subtitles_as.dart';
import './step/the_server_keeps_no_audio_language.dart';
import './step/i_turn_next_episode_autoplay_off.dart';
import './step/the_server_keeps_next_episode_autoplay_off.dart';
import './step/my_settings_cannot_be_loaded.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry.dart';
import './step/this_device_keeps_the_quality_at.dart';
import './step/the_server_cannot_save_settings.dart';
import './step/no_look_was_chosen_yet.dart';
import './step/the_app_shows_in_mode.dart';
import './step/i_pick_the_mode.dart';
import './step/i_restart_the_app.dart';
import './step/my_themes_folder_has_with_the_accent.dart';
import './step/a_file_that_cannot_be_read.dart';
import './step/the_accent_is.dart';
import './step/i_open_the_theme_issues.dart';
import './step/i_see_a_line.dart';
import './step/i_tap.dart';
import './step/the_file_manager_opens.dart';
import './step/was_chosen.dart';
import './step/the_mode_was_chosen.dart';
import './step/i_open_an_episode.dart';
import './step/the_screen_is.dart';
import './step/i_play_the_episode.dart';
import './step/the_player_is.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Settings''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Settings opens from home, with what is set''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Settings opens from home, with what is set''');
        await bddSetUp(tester);
        await myAudioLanguageOnTheServerIs(tester, 'por');
        await mySubtitlesOnTheServerAre(tester, 'Always');
        await myQualityLimitIsMbps(tester, 4);
        await iOpenSettingsFromHome(tester);
        await iSee(tester, '4 Mbps');
        await theAudioLanguageReads(tester, 'Portuguese');
        await iSee(tester, 'Always');
        await iSee(tester, 'alice');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Settings opens from home, with what is set''',
          success,
        );
      }
    });
    testWidgets('''Languages, subtitles and autoplay go to the server''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Languages, subtitles and autoplay go to the server''');
        await bddSetUp(tester);
        await iOpenSettings(tester);
        await iTypeInTheLanguageAndPick(tester, 'port', 'audio', 'Portuguese');
        await theServerKeepsMyLanguageAs(tester, 'audio', 'por');
        await iPickInTheSetting(tester, 'Never', 'subtitles');
        await theServerKeepsMySubtitlesAs(tester, 'Never');
        await iTypeInTheLanguageAndPick(
            tester, 'file', 'audio', "The file's default");
        await theServerKeepsNoAudioLanguage(tester);
        await iTypeInTheLanguageAndPick(tester, 'eng', 'subtitle', 'English');
        await theServerKeepsMyLanguageAs(tester, 'subtitle', 'eng');
        await iTurnNextEpisodeAutoplayOff(tester);
        await theServerKeepsNextEpisodeAutoplayOff(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Languages, subtitles and autoplay go to the server''',
          success,
        );
      }
    });
    testWidgets('''Settings that fail to load can be tried again''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Settings that fail to load can be tried again''');
        await bddSetUp(tester);
        await mySettingsCannotBeLoaded(tester);
        await iOpenSettings(tester);
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await theAudioLanguageReads(tester, "The file's default");
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Settings that fail to load can be tried again''',
          success,
        );
      }
    });
    testWidgets('''The quality is kept on this device''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The quality is kept on this device''');
        await bddSetUp(tester);
        await iOpenSettings(tester);
        await iPickInTheSetting(tester, '2 Mbps', 'quality');
        await thisDeviceKeepsTheQualityAt(tester, '2 Mbps');
        await iPickInTheSetting(tester, 'Maximum', 'quality');
        await thisDeviceKeepsTheQualityAt(tester, 'Maximum');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The quality is kept on this device''',
          success,
        );
      }
    });
    testWidgets('''A save that fails says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A save that fails says so''');
        await bddSetUp(tester);
        await theServerCannotSaveSettings(tester);
        await iOpenSettings(tester);
        await iTypeInTheLanguageAndPick(tester, 'port', 'audio', 'Portuguese');
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A save that fails says so''',
          success,
        );
      }
    });
    testWidgets('''Prime in dark at first; another mode and theme are kept''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Prime in dark at first; another mode and theme are kept''');
        await bddSetUp(tester);
        await noLookWasChosenYet(tester);
        await iOpenSettings(tester);
        await theAppShowsInMode(tester, 'Prime', 'dark');
        await iPickTheMode(tester, 'light');
        await theAppShowsInMode(tester, 'Prime', 'light');
        await iPickInTheSetting(tester, 'Lanterna', 'theme');
        await theAppShowsInMode(tester, 'Lanterna', 'light');
        await iRestartTheApp(tester);
        await iOpenSettings(tester);
        await theAppShowsInMode(tester, 'Lanterna', 'light');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Prime in dark at first; another mode and theme are kept''',
          success,
        );
      }
    });
    testWidgets(
        '''A theme from my folder can be picked; one that cannot be read is reported''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A theme from my folder can be picked; one that cannot be read is reported''');
        await bddSetUp(tester);
        await myThemesFolderHasWithTheAccent(tester, 'Mine', '#ff8800');
        await aFileThatCannotBeRead(tester, 'broken.json');
        await iOpenSettings(tester);
        await iPickInTheSetting(tester, 'Mine (your folder)', 'theme');
        await theAccentIs(tester, '#ff8800');
        await iSee(tester, '1 theme issue');
        await iOpenTheThemeIssues(tester);
        await iSeeALine(tester, 'broken.json: not used');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A theme from my folder can be picked; one that cannot be read is reported''',
          success,
        );
      }
    });
    testWidgets('''My themes folder opens in the file manager''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''My themes folder opens in the file manager''');
        await bddSetUp(tester);
        await iOpenSettings(tester);
        await iTap(tester, 'Open folder');
        await theFileManagerOpens(tester, '/themes');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''My themes folder opens in the file manager''',
          success,
        );
      }
    });
    testWidgets('''Saving my theme's file changes the app as it runs''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Saving my theme's file changes the app as it runs''');
        await bddSetUp(tester);
        await myThemesFolderHasWithTheAccent(tester, 'Mine', '#00a4dc');
        await wasChosen(tester, 'Mine');
        await iOpenSettings(tester);
        await theAccentIs(tester, '#00a4dc');
        await myThemesFolderHasWithTheAccent(tester, 'Mine', '#22cc66');
        await theAccentIs(tester, '#22cc66');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Saving my theme's file changes the app as it runs''',
          success,
        );
      }
    });
    testWidgets('''The player stays dark in light mode''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The player stays dark in light mode''');
        await bddSetUp(tester);
        await theModeWasChosen(tester, 'light');
        await iOpenAnEpisode(tester);
        await theScreenIs(tester, 'light');
        await iPlayTheEpisode(tester);
        await thePlayerIs(tester, 'dark');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The player stays dark in light mode''',
          success,
        );
      }
    });
  });
}
