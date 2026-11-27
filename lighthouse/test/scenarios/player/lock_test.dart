// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_play.dart';
import './step/i_tap_the_button.dart';
import './step/the_controls_are_hidden.dart';
import './step/i_see_the_button.dart';
import './step/i_wait.dart';
import './step/there_is_no_button.dart';
import './step/i_tap_the_video.dart';
import './step/i_hold_the_button_for_seconds.dart';
import './step/the_controls_are_shown.dart';
import './step/the_phones_volume_is_set_to_percent.dart';
import './step/i_swipe_up_percent_of_the_video_on_its_half.dart';
import './step/the_phones_volume_is_percent.dart';
import './step/i_doubletap_the_of_the_video.dart';
import './step/it_is_at_seconds.dart';
import './step/the_phones_volume_keys_do_nothing.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_player_is_still_open.dart';
import './step/the_phones_volume_keys_work.dart';
import './step/i_press.dart';
import './step/it_is_playing.dart';
import './step/i_hold_for_seconds.dart';
import './step/the_episode_reaches_its_last_seconds.dart';
import './step/i_do_not_see_the_up_next_card.dart';
import './step/the_episode_plays_to_its_end.dart';
import './step/is_playing.dart';
import './step/it_plays_to_its_end.dart';
import './step/the_player_is_closed.dart';
import './step/i_see_the_cover.dart';
import './step/the_notification_has_no_buttons.dart';
import './step/i_use_the_notifications.dart';
import './step/the_notification_has_its_buttons.dart';
import './step/it_is_paused.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Locking the player's controls''', () {
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

    testWidgets('''Locked, a tap shows only the padlock''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Locked, a tap shows only the padlock''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await theControlsAreHidden(tester);
        await iSeeTheButton(tester, 'unlock');
        await iWait(tester, '4 seconds');
        await thereIsNoButton(tester, 'unlock');
        await iTapTheVideo(tester);
        await iSeeTheButton(tester, 'unlock');
        await theControlsAreHidden(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Locked, a tap shows only the padlock''',
          success,
        );
      }
    });
    testWidgets('''A short press does not unlock, holding does''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A short press does not unlock, holding does''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await iTapTheButton(tester, 'unlock');
        await theControlsAreHidden(tester);
        await iHoldTheButtonForSeconds(tester, 'unlock', 2);
        await theControlsAreShown(tester);
        await thereIsNoButton(tester, 'unlock');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A short press does not unlock, holding does''',
          success,
        );
      }
    });
    testWidgets('''Locked, swipes and double taps do nothing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Locked, swipes and double taps do nothing''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await thePhonesVolumeIsSetToPercent(tester, 50);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await iSwipeUpPercentOfTheVideoOnItsHalf(tester, 30, 'right');
        await thePhonesVolumeIsPercent(tester, 50);
        await iDoubletapTheOfTheVideo(tester, 'right');
        await itIsAtSeconds(tester, 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Locked, swipes and double taps do nothing''',
          success,
        );
      }
    });
    testWidgets('''Locked, the phone's Back and volume keys do nothing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Locked, the phone's Back and volume keys do nothing''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await thePhonesVolumeKeysDoNothing(tester);
        await iUseThePhonesBack(tester);
        await thePlayerIsStillOpen(tester);
        await iSeeTheButton(tester, 'unlock');
        await iHoldTheButtonForSeconds(tester, 'unlock', 2);
        await thePhonesVolumeKeysWork(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Locked, the phone's Back and volume keys do nothing''',
          success,
        );
      }
    });
    testWidgets(
        '''Locked, keys only show the padlock, and Enter held unlocks''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Locked, keys only show the padlock, and Enter held unlocks''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await iWait(tester, '4 seconds');
        await iPress(tester, 'Space');
        await itIsPlaying(tester);
        await iSeeTheButton(tester, 'unlock');
        await iPress(tester, 'Esc');
        await thePlayerIsStillOpen(tester);
        await iHoldForSeconds(tester, 'Enter', 2);
        await theControlsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Locked, keys only show the padlock, and Enter held unlocks''',
          success,
        );
      }
    });
    testWidgets('''The next episode stays locked''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The next episode stays locked''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await iTapTheButton(tester, 'lock');
        await theEpisodeReachesItsLastSeconds(tester, 6);
        await iDoNotSeeTheUpNextCard(tester);
        await theEpisodePlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
        await theControlsAreHidden(tester);
        await iSeeTheButton(tester, 'unlock');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next episode stays locked''',
          success,
        );
      }
    });
    testWidgets('''Closing the player unlocks''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Closing the player unlocks''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'lock');
        await itPlaysToItsEnd(tester);
        await thePlayerIsClosed(tester);
        await iPlay(tester, 'movie-1');
        await theControlsAreShown(tester);
        await thereIsNoButton(tester, 'unlock');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Closing the player unlocks''',
          success,
        );
      }
    });
    testWidgets(
        '''Locked music keeps its cover and time, its notification no buttons''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Locked music keeps its cover and time, its notification no buttons''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'album-1');
        await iTapTheButton(tester, 'lock');
        await iSeeTheCover(tester);
        await theNotificationHasNoButtons(tester);
        await iUseTheNotifications(tester, 'pause');
        await itIsPlaying(tester);
        await iHoldTheButtonForSeconds(tester, 'unlock', 2);
        await theNotificationHasItsButtons(tester);
        await iUseTheNotifications(tester, 'pause');
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Locked music keeps its cover and time, its notification no buttons''',
          success,
        );
      }
    });
  });
}
