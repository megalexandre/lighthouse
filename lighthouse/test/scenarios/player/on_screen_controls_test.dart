// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/has_a_chapter_from_minute.dart';
import './step/i_play.dart';
import './step/i_hover_three_quarters_along_the_seek_bar.dart';
import './step/i_see.dart';
import './step/i_click_there.dart';
import './step/it_is_at_seconds.dart';
import './step/i_drag_the_seek_bar_from_a_quarter_to_halfway.dart';
import './step/it_seeks_once_to_seconds.dart';
import './step/has_trickplay_pictures.dart';
import './step/i_see_the_picture_of_that_moment.dart';
import './step/seconds_have_played.dart';
import './step/i_tap_the_button.dart';
import './step/i_pick_the_speed.dart';
import './step/it_plays_at_times.dart';
import './step/the_settings_panel_is_closed.dart';
import './step/i_open_the_speed_list.dart';
import './step/i_press.dart';
import './step/the_settings_panel_shows_its_list.dart';
import './step/is_playing.dart';
import './step/the_player_is_closed.dart';
import './step/i_do_not_see_the_big_play_button.dart';
import './step/it_is_playing.dart';
import './step/the_subtitles_are_lifted_above_the_controls.dart';
import './step/i_wait.dart';
import './step/the_subtitles_are_at_the_bottom.dart';
import './step/i_doubleclick_the_video.dart';
import './step/the_player_is_full_screen.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''On-screen controls''', () {
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

    testWidgets(
        '''The seek bar names the chapter under the mouse, and a click seeks there''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The seek bar names the chapter under the mouse, and a click seeks there''');
        await bddSetUp(tester);
        await hasAChapterFromMinute(tester, 'movie-1', 'Storm', 5);
        await iPlay(tester, 'movie-1');
        await iHoverThreeQuartersAlongTheSeekBar(tester);
        await iSee(tester, '7:30');
        await iSee(tester, 'Storm');
        await iClickThere(tester);
        await itIsAtSeconds(tester, 450);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The seek bar names the chapter under the mouse, and a click seeks there''',
          success,
        );
      }
    });
    testWidgets('''Dragging the seek bar seeks once, where it is let go''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Dragging the seek bar seeks once, where it is let go''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iDragTheSeekBarFromAQuarterToHalfway(tester);
        await itSeeksOnceToSeconds(tester, 300);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Dragging the seek bar seeks once, where it is let go''',
          success,
        );
      }
    });
    testWidgets(
        '''The seek bar shows the picture of the moment under the mouse''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The seek bar shows the picture of the moment under the mouse''');
        await bddSetUp(tester);
        await hasTrickplayPictures(tester, 'movie-1');
        await iPlay(tester, 'movie-1');
        await iHoverThreeQuartersAlongTheSeekBar(tester);
        await iSeeThePictureOfThatMoment(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The seek bar shows the picture of the moment under the mouse''',
          success,
        );
      }
    });
    testWidgets('''The buttons skip 10 seconds back and forth''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''The buttons skip 10 seconds back and forth''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iTapTheButton(tester, '+10 s');
        await itIsAtSeconds(tester, 40);
        await iTapTheButton(tester, '-10 s');
        await itIsAtSeconds(tester, 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The buttons skip 10 seconds back and forth''',
          success,
        );
      }
    });
    testWidgets('''The speed, from the settings panel''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The speed, from the settings panel''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'settings');
        await iSee(tester, 'Normal');
        await iPickTheSpeed(tester, 1.5);
        await itPlaysAtTimes(tester, 1.5);
        await theSettingsPanelIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The speed, from the settings panel''',
          success,
        );
      }
    });
    testWidgets(
        '''Esc closes the settings panel a level at a time, then leaves''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Esc closes the settings panel a level at a time, then leaves''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'settings');
        await iOpenTheSpeedList(tester);
        await iPress(tester, 'Esc');
        await theSettingsPanelShowsItsList(tester);
        await iPress(tester, 'Esc');
        await theSettingsPanelIsClosed(tester);
        await isPlaying(tester, 'movie-1');
        await iPress(tester, 'Esc');
        await thePlayerIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Esc closes the settings panel a level at a time, then leaves''',
          success,
        );
      }
    });
    testWidgets('''Paused, a big play button plays''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Paused, a big play button plays''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iDoNotSeeTheBigPlayButton(tester);
        await iPress(tester, 'Space');
        await iTapTheButton(tester, 'big play');
        await itIsPlaying(tester);
        await iDoNotSeeTheBigPlayButton(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Paused, a big play button plays''',
          success,
        );
      }
    });
    testWidgets('''Subtitles rise while the controls are up''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Subtitles rise while the controls are up''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await theSubtitlesAreLiftedAboveTheControls(tester);
        await iWait(tester, '4 seconds');
        await theSubtitlesAreAtTheBottom(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Subtitles rise while the controls are up''',
          success,
        );
      }
    });
    testWidgets('''A double click goes full screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A double click goes full screen''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iDoubleclickTheVideo(tester);
        await thePlayerIsFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A double click goes full screen''',
          success,
        );
      }
    });
  });
}
