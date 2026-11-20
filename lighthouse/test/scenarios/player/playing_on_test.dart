// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/it_plays_to_its_end.dart';
import './step/is_playing.dart';
import './step/the_player_shows.dart';
import './step/it_started_at_seconds.dart';
import './step/the_player_of_the_one_before_is_let_go.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/i_press.dart';
import './step/i_am_back_on_the_page_of.dart';
import './step/there_is_no_button.dart';
import './step/seconds_have_played.dart';
import './step/i_tap_the_button.dart';
import './step/it_is_at_seconds.dart';
import './step/i_see_the_cover.dart';
import './step/i_see.dart';
import './step/i_wait.dart';
import './step/the_controls_are_shown.dart';
import './step/the_player_is_closed.dart';
import './step/i_open_the_page_of.dart';
import './step/i_tap.dart';
import './step/the_player_is_full_screen.dart';
import './step/the_volume_is_muted.dart';
import './step/the_window_is_not_full_screen.dart';
import './step/next_episode_autoplay_is_off.dart';
import './step/the_player_is_let_go.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Playing on''', () {
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

    testWidgets('''At the end of an episode the next one starts''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''At the end of an episode the next one starts''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await itPlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
        await thePlayerShows(tester, 'Episode 2');
        await itStartedAtSeconds(tester, 0);
        await thePlayerOfTheOneBeforeIsLetGo(tester);
        await theServerIsToldStoppedAtSeconds(tester, 'episode-1', 600);
        await iPress(tester, 'Esc');
        await iAmBackOnThePageOf(tester, 'Episode 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''At the end of an episode the next one starts''',
          success,
        );
      }
    });
    testWidgets('''After the last episode, back to its page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''After the last episode, back to its page''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-3');
        await thereIsNoButton(tester, 'next');
        await itPlaysToItsEnd(tester);
        await iAmBackOnThePageOf(tester, 'Episode 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''After the last episode, back to its page''',
          success,
        );
      }
    });
    testWidgets('''Next saves the place and plays the next episode''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Next saves the place and plays the next episode''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await secondsHavePlayed(tester, 20);
        await iTapTheButton(tester, 'next');
        await thePlayerShows(tester, 'Episode 2');
        await theServerIsToldStoppedAtSeconds(tester, 'episode-1', 20);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Next saves the place and plays the next episode''',
          success,
        );
      }
    });
    testWidgets('''Previous restarts the episode, then goes back one''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Previous restarts the episode, then goes back one''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-2');
        await secondsHavePlayed(tester, 10);
        await iTapTheButton(tester, 'previous');
        await thePlayerShows(tester, 'Episode 2');
        await itIsAtSeconds(tester, 0);
        await iTapTheButton(tester, 'previous');
        await thePlayerShows(tester, 'Episode 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Previous restarts the episode, then goes back one''',
          success,
        );
      }
    });
    testWidgets('''Before the first episode, Previous only restarts''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Before the first episode, Previous only restarts''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await secondsHavePlayed(tester, 1);
        await iPress(tester, 'Home');
        await thePlayerShows(tester, 'Episode 1');
        await itIsAtSeconds(tester, 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Before the first episode, Previous only restarts''',
          success,
        );
      }
    });
    testWidgets('''The next-track media key plays the next episode''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''The next-track media key plays the next episode''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await iPress(tester, 'Next track');
        await thePlayerShows(tester, 'Episode 2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next-track media key plays the next episode''',
          success,
        );
      }
    });
    testWidgets('''A movie has no Next''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie has no Next''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await thereIsNoButton(tester, 'next');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie has no Next''',
          success,
        );
      }
    });
    testWidgets('''An album plays through, its cover on screen''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''An album plays through, its cover on screen''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await iSeeTheCover(tester);
        await isPlaying(tester, 'track-1');
        await thePlayerShows(tester, 'Track 1');
        await iSee(tester, 'Test Artist · Test Album');
        await iWait(tester, '5 seconds');
        await theControlsAreShown(tester);
        await itPlaysToItsEnd(tester);
        await thePlayerShows(tester, 'Track 2');
        await itPlaysToItsEnd(tester);
        await thePlayerIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An album plays through, its cover on screen''',
          success,
        );
      }
    });
    testWidgets('''A track picked from the album plays alone''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A track picked from the album plays alone''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'album-1');
        await iTap(tester, 'Track 2');
        await thePlayerShows(tester, 'Track 2');
        await thereIsNoButton(tester, 'next');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A track picked from the album plays alone''',
          success,
        );
      }
    });
    testWidgets('''Full screen and the volume carry on to the next episode''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Full screen and the volume carry on to the next episode''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await iPress(tester, 'F');
        await iPress(tester, 'Down');
        await iPress(tester, 'Down');
        await iPress(tester, 'M');
        await thePlayerIsFullScreen(tester);
        await theVolumeIsMuted(tester, 90);
        await itPlaysToItsEnd(tester);
        await thePlayerShows(tester, 'Episode 2');
        await thePlayerIsFullScreen(tester);
        await theVolumeIsMuted(tester, 90);
        await iPress(tester, 'Next track');
        await thePlayerIsFullScreen(tester);
        await iPress(tester, 'Esc');
        await thePlayerIsClosed(tester);
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Full screen and the volume carry on to the next episode''',
          success,
        );
      }
    });
    testWidgets(
        '''With autoplay off, the player closes at the end of an episode''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''With autoplay off, the player closes at the end of an episode''');
        await bddSetUp(tester);
        await nextEpisodeAutoplayIsOff(tester);
        await iPlay(tester, 'episode-1');
        await itPlaysToItsEnd(tester);
        await iAmBackOnThePageOf(tester, 'Episode 1');
        await thePlayerIsLetGo(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''With autoplay off, the player closes at the end of an episode''',
          success,
        );
      }
    });
  });
}
