// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_play.dart';
import './step/the_screen_goes_off.dart';
import './step/it_plays_to_its_end_without_a_frame.dart';
import './step/the_stream_of_is_open.dart';
import './step/only_its_sound_was_opened.dart';
import './step/the_notification_shows.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/the_screen_comes_back_on.dart';
import './step/the_player_shows.dart';
import './step/there_is_no_notification.dart';
import './step/other_apps_can_play.dart';
import './step/the_player_is_closed.dart';
import './step/i_use_the_notifications.dart';
import './step/the_notification_has_no_next.dart';
import './step/seconds_have_played.dart';
import './step/the_notification_is_at_seconds.dart';
import './step/it_is_paused.dart';
import './step/the_notification_shows_it.dart';
import './step/it_is_playing.dart';
import './step/i_dismiss_the_notification.dart';
import './step/i_tap_the_button.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_next_song_cannot_be_reached.dart';
import './step/it_plays_to_its_end.dart';
import './step/the_server_can_be_reached_again.dart';
import './step/i_tap_retry.dart';
import './step/a_call_comes_in.dart';
import './step/the_call_ends.dart';
import './step/another_app_starts_playing.dart';
import './step/the_headphones_are_unplugged.dart';
import './step/a_call_is_on.dart';
import './step/is_playing.dart';
import './step/the_sound_is_the_apps.dart';
import './step/the_phone_is_held_sideways.dart';
import './step/the_player_is_full_screen.dart';
import './step/the_phone_turns_freely.dart';
import './step/the_window_is_not_full_screen.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Playing in the background''', () {
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

    testWidgets('''An album plays through with the screen off''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''An album plays through with the screen off''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await theScreenGoesOff(tester);
        await itPlaysToItsEndWithoutAFrame(tester);
        await theStreamOfIsOpen(tester, 'track-2');
        await onlyItsSoundWasOpened(tester);
        await theNotificationShows(tester, 'Track 2');
        await theServerIsToldStoppedAtSeconds(tester, 'track-1', 600);
        await theScreenComesBackOn(tester);
        await thePlayerShows(tester, 'Track 2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An album plays through with the screen off''',
          success,
        );
      }
    });
    testWidgets('''After the last song the notification goes''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''After the last song the notification goes''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await theScreenGoesOff(tester);
        await itPlaysToItsEndWithoutAFrame(tester);
        await itPlaysToItsEndWithoutAFrame(tester);
        await thereIsNoNotification(tester);
        await otherAppsCanPlay(tester);
        await theScreenComesBackOn(tester);
        await thePlayerIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''After the last song the notification goes''',
          success,
        );
      }
    });
    testWidgets('''The notification changes songs''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The notification changes songs''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await theNotificationShows(tester, 'Track 1');
        await iUseTheNotifications(tester, 'next');
        await thePlayerShows(tester, 'Track 2');
        await theNotificationShows(tester, 'Track 2');
        await theNotificationHasNoNext(tester);
        await iUseTheNotifications(tester, 'previous');
        await thePlayerShows(tester, 'Track 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The notification changes songs''',
          success,
        );
      }
    });
    testWidgets('''Previous restarts a song that is under way''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Previous restarts a song that is under way''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await secondsHavePlayed(tester, 30);
        await theNotificationIsAtSeconds(tester, 30);
        await iUseTheNotifications(tester, 'previous');
        await theNotificationShows(tester, 'Track 1');
        await theNotificationIsAtSeconds(tester, 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Previous restarts a song that is under way''',
          success,
        );
      }
    });
    testWidgets('''The notification pauses and plays''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The notification pauses and plays''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await iUseTheNotifications(tester, 'pause');
        await itIsPaused(tester);
        await theNotificationShowsIt(tester, 'paused');
        await iUseTheNotifications(tester, 'play');
        await itIsPlaying(tester);
        await theNotificationShowsIt(tester, 'playing');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The notification pauses and plays''',
          success,
        );
      }
    });
    testWidgets(
        '''Dismissing the notification pauses; it comes back with the music''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Dismissing the notification pauses; it comes back with the music''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await iDismissTheNotification(tester);
        await itIsPaused(tester);
        await thereIsNoNotification(tester);
        await otherAppsCanPlay(tester);
        await iTapTheButton(tester, 'play/pause');
        await itIsPlaying(tester);
        await theNotificationShows(tester, 'Track 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Dismissing the notification pauses; it comes back with the music''',
          success,
        );
      }
    });
    testWidgets('''Leaving the player takes the notification with it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Leaving the player takes the notification with it''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await iUseThePhonesBack(tester);
        await thePlayerIsClosed(tester);
        await thereIsNoNotification(tester);
        await otherAppsCanPlay(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Leaving the player takes the notification with it''',
          success,
        );
      }
    });
    testWidgets('''A song that cannot be reached can be tried again''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A song that cannot be reached can be tried again''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await theNextSongCannotBeReached(tester);
        await itPlaysToItsEnd(tester);
        await thereIsNoNotification(tester);
        await theServerCanBeReachedAgain(tester);
        await iTapRetry(tester);
        await thePlayerShows(tester, 'Track 2');
        await theNotificationShows(tester, 'Track 2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A song that cannot be reached can be tried again''',
          success,
        );
      }
    });
    testWidgets('''Video has no notification''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Video has no notification''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await thereIsNoNotification(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Video has no notification''',
          success,
        );
      }
    });
    testWidgets('''A call pauses the music, which goes on after it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A call pauses the music, which goes on after it''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await aCallComesIn(tester);
        await itIsPaused(tester);
        await theCallEnds(tester);
        await itIsPlaying(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A call pauses the music, which goes on after it''',
          success,
        );
      }
    });
    testWidgets('''Music paused by hand during a call stays paused''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Music paused by hand during a call stays paused''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await aCallComesIn(tester);
        await iUseTheNotifications(tester, 'pause');
        await theCallEnds(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Music paused by hand during a call stays paused''',
          success,
        );
      }
    });
    testWidgets('''Music that was paused stays so after a call''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Music that was paused stays so after a call''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await iUseTheNotifications(tester, 'pause');
        await aCallComesIn(tester);
        await theCallEnds(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Music that was paused stays so after a call''',
          success,
        );
      }
    });
    testWidgets('''Another app's music stops this one for good''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Another app's music stops this one for good''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await anotherAppStartsPlaying(tester);
        await itIsPaused(tester);
        await theCallEnds(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Another app's music stops this one for good''',
          success,
        );
      }
    });
    testWidgets('''Unplugging the headphones pauses''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Unplugging the headphones pauses''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await theHeadphonesAreUnplugged(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Unplugging the headphones pauses''',
          success,
        );
      }
    });
    testWidgets('''During a call nothing starts playing''', (tester) async {
      var success = true;
      try {
        await beforeEach('''During a call nothing starts playing''');
        await bddSetUp(tester);
        await aCallIsOn(tester);
        await iPlay(tester, 'movie-1');
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''During a call nothing starts playing''',
          success,
        );
      }
    });
    testWidgets('''A video paused by a call does not play in the background''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A video paused by a call does not play in the background''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await aCallComesIn(tester);
        await theScreenGoesOff(tester);
        await theCallEnds(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A video paused by a call does not play in the background''',
          success,
        );
      }
    });
    testWidgets('''The next episode keeps the sound''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The next episode keeps the sound''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await itPlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
        await itIsPlaying(tester);
        await theSoundIsTheApps(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next episode keeps the sound''',
          success,
        );
      }
    });
    testWidgets('''A video plays sideways and full screen, until it is left''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A video plays sideways and full screen, until it is left''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await thePhoneIsHeldSideways(tester);
        await thePlayerIsFullScreen(tester);
        await iUseThePhonesBack(tester);
        await thePlayerIsClosed(tester);
        await thePhoneTurnsFreely(tester);
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A video plays sideways and full screen, until it is left''',
          success,
        );
      }
    });
    testWidgets('''The next episode stays sideways''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The next episode stays sideways''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await itPlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
        await thePhoneIsHeldSideways(tester);
        await thePlayerIsFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next episode stays sideways''',
          success,
        );
      }
    });
    testWidgets('''Music leaves the phone as it is held''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Music leaves the phone as it is held''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await thePhoneTurnsFreely(tester);
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Music leaves the phone as it is held''',
          success,
        );
      }
    });
  });
}
