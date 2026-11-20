// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_open_the_page_of.dart';
import './step/i_see_the_page_of.dart';
import './step/i_see.dart';
import './step/there_is_no_link_to_a_series.dart';
import './step/i_open.dart';
import './step/i_open_the_series.dart';
import './step/each_track_shows.dart';
import './step/is_in1080p_with51_sound_and_subtitles.dart';
import './step/i_see_the_badges_and.dart';
import './step/the_cannot_be_loaded.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry.dart';
import './step/has_no_episodes.dart';
import './step/was_watched.dart';
import './step/is_about.dart';
import './step/the_episode_shows_it_was_watched.dart';
import './step/the_episode_does_not_show_it_was_watched.dart';
import './step/has_no_number.dart';
import './step/the_server_cannot_save_what_was_watched_or_read.dart';
import './step/i_tap_the_button.dart';
import './step/i_see_a_message.dart';
import './step/the_item_cannot_be_loaded.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Item page''', () {
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

    testWidgets('''A movie: title, facts and overview''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie: title, facts and overview''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'Test Movie');
        await iSeeThePageOf(tester, 'Test Movie');
        await iSee(tester, '2020 · 1h 32m · PG');
        await iSee(tester, 'A movie made for tests.');
        await thereIsNoLinkToASeries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie: title, facts and overview''',
          success,
        );
      }
    });
    testWidgets('''From a series down to an episode, and back up''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''From a series down to an episode, and back up''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'Test Show');
        await iSee(tester, 'Seasons');
        await iOpen(tester, 'Season 1');
        await iSeeThePageOf(tester, 'Season 1');
        await iSee(tester, '1. Episode 1');
        await iSee(tester, '2. Episode 2');
        await iSee(tester, '3. Episode 3');
        await iOpen(tester, '2. Episode 2');
        await iSeeThePageOf(tester, 'Episode 2');
        await iSee(tester, 'S1:E2 · 45m');
        await iOpenTheSeries(tester);
        await iSeeThePageOf(tester, 'Test Show');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''From a series down to an episode, and back up''',
          success,
        );
      }
    });
    testWidgets('''An album lists its tracks''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An album lists its tracks''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'Test Album');
        await iSeeThePageOf(tester, 'Test Album');
        await iSee(tester, 'Test Artist');
        await iSee(tester, 'Track 1');
        await iSee(tester, 'Track 2');
        await eachTrackShows(tester, '3m');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An album lists its tracks''',
          success,
        );
      }
    });
    testWidgets('''The picture and the sound show as badges''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The picture and the sound show as badges''');
        await bddSetUp(tester);
        await isIn1080pWith51SoundAndSubtitles(tester, 'Test Movie');
        await iOpenThePageOf(tester, 'Test Movie');
        await iSeeTheBadgesAnd(tester, '1080P', '5.1', 'CC');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The picture and the sound show as badges''',
          success,
        );
      }
    });
    testWidgets(
        '''The <section> that fail to load can be tried again, the page still shows ('seasons', 'Test Show', 'Season 1')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The <section> that fail to load can be tried again, the page still shows ('seasons', 'Test Show', 'Season 1')''');
        await bddSetUp(tester);
        await theCannotBeLoaded(tester, 'seasons');
        await iOpenThePageOf(tester, 'Test Show');
        await iSeeThePageOf(tester, 'Test Show');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSee(tester, 'Season 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The <section> that fail to load can be tried again, the page still shows ('seasons', 'Test Show', 'Season 1')''',
          success,
        );
      }
    });
    testWidgets(
        '''The <section> that fail to load can be tried again, the page still shows ('episodes', 'Season 1', '1. Episode 1')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The <section> that fail to load can be tried again, the page still shows ('episodes', 'Season 1', '1. Episode 1')''');
        await bddSetUp(tester);
        await theCannotBeLoaded(tester, 'episodes');
        await iOpenThePageOf(tester, 'Season 1');
        await iSeeThePageOf(tester, 'Season 1');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSee(tester, '1. Episode 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The <section> that fail to load can be tried again, the page still shows ('episodes', 'Season 1', '1. Episode 1')''',
          success,
        );
      }
    });
    testWidgets(
        '''The <section> that fail to load can be tried again, the page still shows ('tracks', 'Test Album', 'Track 1')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The <section> that fail to load can be tried again, the page still shows ('tracks', 'Test Album', 'Track 1')''');
        await bddSetUp(tester);
        await theCannotBeLoaded(tester, 'tracks');
        await iOpenThePageOf(tester, 'Test Album');
        await iSeeThePageOf(tester, 'Test Album');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSee(tester, 'Track 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The <section> that fail to load can be tried again, the page still shows ('tracks', 'Test Album', 'Track 1')''',
          success,
        );
      }
    });
    testWidgets('''A season without episodes says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A season without episodes says so''');
        await bddSetUp(tester);
        await hasNoEpisodes(tester, 'Season 1');
        await iOpenThePageOf(tester, 'Season 1');
        await iSee(tester, 'Nothing here yet.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A season without episodes says so''',
          success,
        );
      }
    });
    testWidgets(
        '''A season's episodes show which were watched, and what each is about''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A season's episodes show which were watched, and what each is about''');
        await bddSetUp(tester);
        await wasWatched(tester, 'Episode 1');
        await isAbout(tester, 'Episode 2', 'The second one.');
        await iOpenThePageOf(tester, 'Season 1');
        await theEpisodeShowsItWasWatched(tester, 'Episode 1');
        await theEpisodeDoesNotShowItWasWatched(tester, 'Episode 2');
        await iSee(tester, 'The second one.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A season's episodes show which were watched, and what each is about''',
          success,
        );
      }
    });
    testWidgets('''An episode without a number goes by its name alone''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''An episode without a number goes by its name alone''');
        await bddSetUp(tester);
        await hasNoNumber(tester, 'Episode 3');
        await iOpenThePageOf(tester, 'Season 1');
        await iSee(tester, 'Episode 3');
        await iSee(tester, '1. Episode 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An episode without a number goes by its name alone''',
          success,
        );
      }
    });
    testWidgets(
        '''Marking a <kind> <what> when the server cannot save it says so (movie, watched, 'Test Movie', 'Mark as watched')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Marking a <kind> <what> when the server cannot save it says so (movie, watched, 'Test Movie', 'Mark as watched')''');
        await bddSetUp(tester);
        await theServerCannotSaveWhatWasWatchedOrRead(tester);
        await iOpenThePageOf(tester, 'Test Movie');
        await iTapTheButton(tester, 'Mark as watched');
        await iSeeAMessage(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Marking a <kind> <what> when the server cannot save it says so (movie, watched, 'Test Movie', 'Mark as watched')''',
          success,
        );
      }
    });
    testWidgets(
        '''Marking a <kind> <what> when the server cannot save it says so (book, read, 'Test Comic', 'Mark as read')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Marking a <kind> <what> when the server cannot save it says so (book, read, 'Test Comic', 'Mark as read')''');
        await bddSetUp(tester);
        await theServerCannotSaveWhatWasWatchedOrRead(tester);
        await iOpenThePageOf(tester, 'Test Comic');
        await iTapTheButton(tester, 'Mark as read');
        await iSeeAMessage(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Marking a <kind> <what> when the server cannot save it says so (book, read, 'Test Comic', 'Mark as read')''',
          success,
        );
      }
    });
    testWidgets('''A page that fails to load can be tried again''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A page that fails to load can be tried again''');
        await bddSetUp(tester);
        await theItemCannotBeLoaded(tester);
        await iOpenThePageOf(tester, 'Test Movie');
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSeeThePageOf(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A page that fails to load can be tried again''',
          success,
        );
      }
    });
  });
}
