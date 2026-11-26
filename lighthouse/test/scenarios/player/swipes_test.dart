// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/the_phones_volume_is_set_to_percent.dart';
import './step/i_play.dart';
import './step/i_swipe_up_percent_of_the_video_on_its_half.dart';
import './step/the_phones_volume_is_percent.dart';
import './step/i_swipe_down_percent_of_the_video_on_its_half.dart';
import './step/the_screens_brightness_is_set_to_percent.dart';
import './step/the_screens_brightness_is_percent.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_player_is_closed.dart';
import './step/the_screen_is_back_to_its_own_brightness.dart';
import './step/seconds_have_played.dart';
import './step/i_put_a_finger_down_and_slide_it_percent_of_the_video_to_the.dart';
import './step/the_swipe_shows.dart';
import './step/it_is_at_seconds.dart';
import './step/i_lift_the_finger.dart';
import './step/i_swipe_percent_of_the_video_to_the.dart';
import './step/i_swipe_up_from_the_bottom_edge_on_the_half.dart';
import './step/i_turn_off_in_settings.dart';
import './step/i_scroll_down_over_the_video.dart';
import './step/the_volume_is.dart';
import './step/i_scroll_up_over_the_video.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Swipes on the video''', () {
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
        '''Up on the right half raises the phone's volume, down lowers it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Up on the right half raises the phone's volume, down lowers it''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await thePhonesVolumeIsSetToPercent(tester, 20);
        await iPlay(tester, 'movie-1');
        await iSwipeUpPercentOfTheVideoOnItsHalf(tester, 30, 'right');
        await thePhonesVolumeIsPercent(tester, 70);
        await iSwipeDownPercentOfTheVideoOnItsHalf(tester, 60, 'right');
        await thePhonesVolumeIsPercent(tester, 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Up on the right half raises the phone's volume, down lowers it''',
          success,
        );
      }
    });
    testWidgets(
        '''Up on the left half brightens the screen until the player closes''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Up on the left half brightens the screen until the player closes''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await theScreensBrightnessIsSetToPercent(tester, 50);
        await iPlay(tester, 'movie-1');
        await iSwipeUpPercentOfTheVideoOnItsHalf(tester, 15, 'left');
        await theScreensBrightnessIsPercent(tester, 75);
        await iUseThePhonesBack(tester);
        await thePlayerIsClosed(tester);
        await theScreenIsBackToItsOwnBrightness(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Up on the left half brightens the screen until the player closes''',
          success,
        );
      }
    });
    testWidgets('''Sideways seeks when the finger lifts, showing where to''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Sideways seeks when the finger lifts, showing where to''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iPutAFingerDownAndSlideItPercentOfTheVideoToThe(
            tester, 50, 'right');
        await theSwipeShows(tester, '+1:00');
        await itIsAtSeconds(tester, 30);
        await iLiftTheFinger(tester);
        await itIsAtSeconds(tester, 90);
        await iSwipePercentOfTheVideoToThe(tester, 50, 'left');
        await itIsAtSeconds(tester, 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Sideways seeks when the finger lifts, showing where to''',
          success,
        );
      }
    });
    testWidgets('''A swipe from an edge is left to the system''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A swipe from an edge is left to the system''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await thePhonesVolumeIsSetToPercent(tester, 20);
        await iPlay(tester, 'movie-1');
        await iSwipeUpFromTheBottomEdgeOnTheHalf(tester, 'right');
        await thePhonesVolumeIsPercent(tester, 20);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A swipe from an edge is left to the system''',
          success,
        );
      }
    });
    testWidgets('''Turned off in Settings, the swipes do nothing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Turned off in Settings, the swipes do nothing''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await thePhonesVolumeIsSetToPercent(tester, 20);
        await iTurnOffInSettings(tester, 'Swipe for brightness and volume');
        await iTurnOffInSettings(tester, 'Swipe to seek');
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iSwipeUpPercentOfTheVideoOnItsHalf(tester, 30, 'right');
        await iSwipePercentOfTheVideoToThe(tester, 50, 'right');
        await thePhonesVolumeIsPercent(tester, 20);
        await itIsAtSeconds(tester, 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Turned off in Settings, the swipes do nothing''',
          success,
        );
      }
    });
    testWidgets('''With a mouse, the wheel over the video changes the volume''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''With a mouse, the wheel over the video changes the volume''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iScrollDownOverTheVideo(tester);
        await theVolumeIs(tester, 95);
        await iScrollUpOverTheVideo(tester);
        await theVolumeIs(tester, 100);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''With a mouse, the wheel over the video changes the volume''',
          success,
        );
      }
    });
  });
}
