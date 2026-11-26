// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/has_been_watched.dart';
import './step/i_play.dart';
import './step/i_tap_the_button.dart';
import './step/the_panel_lists.dart';
import './step/the_panel_marks_as_playing.dart';
import './step/the_panel_marks_as_watched.dart';
import './step/i_pick_in_the_panel.dart';
import './step/the_stream_of_is_open.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/the_series_has_a_second_season_with.dart';
import './step/has_a_chapter_from_minute.dart';
import './step/it_is_at_seconds.dart';
import './step/there_is_no_button.dart';
import './step/i_press.dart';
import './step/the_side_panel_is_open.dart';
import './step/the_side_panel_is_closed.dart';
import './step/the_player_is_still_open.dart';
import './step/it_is_paused.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_player_is_closed.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''The player's side panel''', () {
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

    testWidgets('''An episode's panel lists the series and plays another''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''An episode's panel lists the series and plays another''');
        await bddSetUp(tester);
        await hasBeenWatched(tester, 'episode-1');
        await iPlay(tester, 'episode-2');
        await iTapTheButton(tester, 'episodes');
        await thePanelLists(tester, '1. Episode 1, 2. Episode 2, 3. Episode 3');
        await thePanelMarksAsPlaying(tester, '2. Episode 2');
        await thePanelMarksAsWatched(tester, 'episode-1');
        await iPickInThePanel(tester, '3. Episode 3');
        await theStreamOfIsOpen(tester, 'episode-3');
        await theServerIsToldStoppedAtSeconds(tester, 'episode-2', 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An episode's panel lists the series and plays another''',
          success,
        );
      }
    });
    testWidgets('''The seasons are tabs, the playing one's first''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''The seasons are tabs, the playing one's first''');
        await bddSetUp(tester);
        await theSeriesHasASecondSeasonWith(tester, 'Episode 4');
        await iPlay(tester, 'episode-1');
        await iTapTheButton(tester, 'episodes');
        await thePanelLists(tester, '1. Episode 1, 2. Episode 2, 3. Episode 3');
        await iPickInThePanel(tester, 'Season 2');
        await thePanelLists(tester, '1. Episode 4');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The seasons are tabs, the playing one's first''',
          success,
        );
      }
    });
    testWidgets('''A movie's panel lists its chapters and goes to one''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A movie's panel lists its chapters and goes to one''');
        await bddSetUp(tester);
        await hasAChapterFromMinute(tester, 'movie-1', 'Storm', 5);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'chapters');
        await thePanelLists(tester, 'Opening, Storm');
        await thePanelMarksAsPlaying(tester, 'Opening');
        await iPickInThePanel(tester, 'Storm');
        await itIsAtSeconds(tester, 300);
        await thePanelMarksAsPlaying(tester, 'Storm');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie's panel lists its chapters and goes to one''',
          success,
        );
      }
    });
    testWidgets('''A movie without chapters has no panel''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie without chapters has no panel''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await thereIsNoButton(tester, 'chapters');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie without chapters has no panel''',
          success,
        );
      }
    });
    testWidgets('''C opens it, Esc closes it and not the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''C opens it, Esc closes it and not the player''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await iPress(tester, 'C');
        await theSidePanelIsOpen(tester);
        await iPress(tester, 'Esc');
        await theSidePanelIsClosed(tester);
        await thePlayerIsStillOpen(tester);
        await iPress(tester, 'Space');
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''C opens it, Esc closes it and not the player''',
          success,
        );
      }
    });
    testWidgets('''On a phone, Back closes the panel, then the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a phone, Back closes the panel, then the player''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'episode-1');
        await iTapTheButton(tester, 'episodes');
        await iUseThePhonesBack(tester);
        await theSidePanelIsClosed(tester);
        await thePlayerIsStillOpen(tester);
        await iUseThePhonesBack(tester);
        await thePlayerIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a phone, Back closes the panel, then the player''',
          success,
        );
      }
    });
  });
}
