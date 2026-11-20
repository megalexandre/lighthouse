// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_play.dart';
import './step/the_controls_are_shown.dart';
import './step/i_tap_the_video.dart';
import './step/the_controls_are_hidden.dart';
import './step/it_is_playing.dart';
import './step/seconds_have_played.dart';
import './step/i_doubletap_the_of_the_video.dart';
import './step/it_is_at_seconds.dart';
import './step/there_is_no_button.dart';
import './step/i_slide_a_finger_along_the_seek_bar.dart';
import './step/the_seek_bar_shows_where_it_would_go.dart';
import './step/i_lift_the_finger.dart';
import './step/the_seek_bar_shows_no_preview.dart';
import './step/i_open_the_subtitles_in_the_settings_panel.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_settings_panel_shows_its_list.dart';
import './step/the_settings_panel_is_closed.dart';
import './step/the_player_is_still_open.dart';
import './step/the_player_is_closed.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''The player on touch''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await theAppRunsOnA(tester, 'phone');
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''A tap hides the controls and another shows them, and neither pauses''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A tap hides the controls and another shows them, and neither pauses''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await theControlsAreShown(tester);
        await iTapTheVideo(tester);
        await theControlsAreHidden(tester);
        await itIsPlaying(tester);
        await iTapTheVideo(tester);
        await theControlsAreShown(tester);
        await itIsPlaying(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tap hides the controls and another shows them, and neither pauses''',
          success,
        );
      }
    });
    testWidgets(
        '''A double tap on the right goes on 10 seconds, on the left back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A double tap on the right goes on 10 seconds, on the left back''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iDoubletapTheOfTheVideo(tester, 'right');
        await itIsAtSeconds(tester, 40);
        await iDoubletapTheOfTheVideo(tester, 'left');
        await itIsAtSeconds(tester, 30);
        await itIsPlaying(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A double tap on the right goes on 10 seconds, on the left back''',
          success,
        );
      }
    });
    testWidgets('''No volume button: the phone has keys for it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''No volume button: the phone has keys for it''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await thereIsNoButton(tester, 'mute');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''No volume button: the phone has keys for it''',
          success,
        );
      }
    });
    testWidgets('''The seek bar's preview goes when the finger lifts''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The seek bar's preview goes when the finger lifts''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iSlideAFingerAlongTheSeekBar(tester);
        await theSeekBarShowsWhereItWouldGo(tester);
        await iLiftTheFinger(tester);
        await theSeekBarShowsNoPreview(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The seek bar's preview goes when the finger lifts''',
          success,
        );
      }
    });
    testWidgets(
        '''Back goes up the settings panel, closes it, then leaves the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Back goes up the settings panel, closes it, then leaves the player''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 42);
        await iOpenTheSubtitlesInTheSettingsPanel(tester);
        await iUseThePhonesBack(tester);
        await theSettingsPanelShowsItsList(tester);
        await iUseThePhonesBack(tester);
        await theSettingsPanelIsClosed(tester);
        await thePlayerIsStillOpen(tester);
        await iUseThePhonesBack(tester);
        await thePlayerIsClosed(tester);
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 42);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Back goes up the settings panel, closes it, then leaves the player''',
          success,
        );
      }
    });
  });
}
