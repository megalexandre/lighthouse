// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/is_playing.dart';
import './step/it_started_at_seconds.dart';
import './step/the_server_is_told_started.dart';
import './step/was_stopped_at_seconds.dart';
import './step/i_open_the_page_of.dart';
import './step/i_see.dart';
import './step/i_tap_the_button.dart';
import './step/seconds_have_played.dart';
import './step/i_am_back_on_the_page_of.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/the_player_is_let_go.dart';
import './step/i_press.dart';
import './step/it_is_paused.dart';
import './step/the_server_is_told_it_is_paused.dart';
import './step/i_see_the_big_play_button.dart';
import './step/i_see_a_button.dart';
import './step/it_is_playing.dart';
import './step/the_server_is_told_it_is_playing.dart';
import './step/it_is_at_seconds.dart';
import './step/the_position_reads.dart';
import './step/the_controls_are_shown.dart';
import './step/i_wait.dart';
import './step/the_controls_are_hidden.dart';
import './step/it_plays_to_its_end.dart';
import './step/the_player_is_closed.dart';
import './step/cannot_be_played.dart';
import './step/no_stream_is_opened.dart';
import './step/the_server_is_told_was_watched.dart';
import './step/there_is_no_button.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Playing''', () {
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

    testWidgets('''Play starts the movie from the beginning''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Play starts the movie from the beginning''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await isPlaying(tester, 'movie-1');
        await itStartedAtSeconds(tester, 0);
        await theServerIsToldStarted(tester, 'movie-1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Play starts the movie from the beginning''',
          success,
        );
      }
    });
    testWidgets('''A movie stopped partway offers to resume''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie stopped partway offers to resume''');
        await bddSetUp(tester);
        await wasStoppedAtSeconds(tester, 'movie-1', 64);
        await iOpenThePageOf(tester, 'movie-1');
        await iSee(tester, 'Resume from 1:04');
        await iSee(tester, 'Start over');
        await iTapTheButton(tester, 'resume');
        await itStartedAtSeconds(tester, 64);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie stopped partway offers to resume''',
          success,
        );
      }
    });
    testWidgets('''Back saves the place and returns to the page''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Back saves the place and returns to the page''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 42);
        await iTapTheButton(tester, 'back');
        await iAmBackOnThePageOf(tester, 'Test Movie');
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 42);
        await thePlayerIsLetGo(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Back saves the place and returns to the page''',
          success,
        );
      }
    });
    testWidgets('''Esc leaves too''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Esc leaves too''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'Esc');
        await iAmBackOnThePageOf(tester, 'Test Movie');
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Esc leaves too''',
          success,
        );
      }
    });
    testWidgets('''The button and Space pause and play''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The button and Space pause and play''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'play/pause');
        await itIsPaused(tester);
        await theServerIsToldItIsPaused(tester);
        await iSeeTheBigPlayButton(tester);
        await iSeeAButton(tester, 'Play (Space)');
        await iPress(tester, 'Space');
        await itIsPlaying(tester);
        await theServerIsToldItIsPlaying(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The button and Space pause and play''',
          success,
        );
      }
    });
    testWidgets('''The arrows seek 10 seconds, never before the start''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The arrows seek 10 seconds, never before the start''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'Right');
        await itIsAtSeconds(tester, 10);
        await iPress(tester, 'Left');
        await iPress(tester, 'Left');
        await itIsAtSeconds(tester, 0);
        await thePositionReads(tester, '0:00');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The arrows seek 10 seconds, never before the start''',
          success,
        );
      }
    });
    testWidgets('''The controls hide while playing, and stay while paused''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The controls hide while playing, and stay while paused''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await theControlsAreShown(tester);
        await iWait(tester, '4 seconds');
        await theControlsAreHidden(tester);
        await iPress(tester, 'Space');
        await theControlsAreShown(tester);
        await iWait(tester, '4 seconds');
        await theControlsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The controls hide while playing, and stay while paused''',
          success,
        );
      }
    });
    testWidgets('''Played to the end, the player closes and the server knows''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Played to the end, the player closes and the server knows''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await itPlaysToItsEnd(tester);
        await thePlayerIsClosed(tester);
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 600);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Played to the end, the player closes and the server knows''',
          success,
        );
      }
    });
    testWidgets('''What cannot be played says why''', (tester) async {
      var success = true;
      try {
        await beforeEach('''What cannot be played says why''');
        await bddSetUp(tester);
        await cannotBePlayed(tester, 'movie-1');
        await iPlay(tester, 'movie-1');
        await iSee(tester, 'This item cannot be played (NotAllowed).');
        await noStreamIsOpened(tester);
        await iTapTheButton(tester, 'back');
        await iAmBackOnThePageOf(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''What cannot be played says why''',
          success,
        );
      }
    });
    testWidgets('''Marking as watched tells the server''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Marking as watched tells the server''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'movie-1');
        await iTapTheButton(tester, 'watched');
        await theServerIsToldWasWatched(tester, 'movie-1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Marking as watched tells the server''',
          success,
        );
      }
    });
    testWidgets('''Series have no Play button''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Series have no Play button''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'series-1');
        await thereIsNoButton(tester, 'play');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Series have no Play button''',
          success,
        );
      }
    });
  });
}
