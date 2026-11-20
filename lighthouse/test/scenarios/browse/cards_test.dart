// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/was_watched.dart';
import './step/is_percent_watched.dart';
import './step/i_open_the_library.dart';
import './step/the_card_of_shows_a_check.dart';
import './step/the_card_of_shows_how_far_it_got.dart';
import './step/the_card_of_has_no_play_button.dart';
import './step/i_rest_the_mouse_on.dart';
import './step/the_card_of_is_lifted.dart';
import './step/after_a_moment_no_panel_opens.dart';
import './step/i_tap_the_play_button_of.dart';
import './step/the_player_is_open.dart';
import './step/animations_are_reduced.dart';
import './step/the_card_of_has_a_play_button.dart';
import './step/the_card_of_is_not_lifted.dart';
import './step/i_open.dart';
import './step/i_see_the_page_of.dart';
import './step/the_theme_is.dart';
import './step/after_half_a_moment_no_panel_is_open.dart';
import './step/after_a_moment_the_panel_opens.dart';
import './step/the_panel_shows.dart';
import './step/i_move_the_mouse_away.dart';
import './step/the_panel_is_closed.dart';
import './step/i_tap_in_the_panel.dart';
import './step/the_server_is_told_was_watched.dart';
import './step/i_go_back.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Cards''', () {
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
        '''A watched item shows a check; a started one, how far it got''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A watched item shows a check; a started one, how far it got''');
        await bddSetUp(tester);
        await wasWatched(tester, 'Test Movie');
        await isPercentWatched(tester, 'HEVC Movie', 30);
        await iOpenTheLibrary(tester, 'Movies');
        await theCardOfShowsACheck(tester, 'Test Movie');
        await theCardOfShowsHowFarItGot(tester, 'HEVC Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A watched item shows a check; a started one, how far it got''',
          success,
        );
      }
    });
    testWidgets(
        '''Under the mouse a card lifts and shows Play, which plays at once''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Under the mouse a card lifts and shows Play, which plays at once''');
        await bddSetUp(tester);
        await iOpenTheLibrary(tester, 'Movies');
        await theCardOfHasNoPlayButton(tester, 'Test Movie');
        await iRestTheMouseOn(tester, 'Test Movie');
        await theCardOfIsLifted(tester, 'Test Movie');
        await afterAMomentNoPanelOpens(tester);
        await iTapThePlayButtonOf(tester, 'Test Movie');
        await thePlayerIsOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Under the mouse a card lifts and shows Play, which plays at once''',
          success,
        );
      }
    });
    testWidgets('''With reduced motion the card does not grow''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''With reduced motion the card does not grow''');
        await bddSetUp(tester);
        await animationsAreReduced(tester);
        await iOpenTheLibrary(tester, 'Movies');
        await iRestTheMouseOn(tester, 'Test Movie');
        await theCardOfHasAPlayButton(tester, 'Test Movie');
        await theCardOfIsNotLifted(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''With reduced motion the card does not grow''',
          success,
        );
      }
    });
    testWidgets('''A series has no play button; it opens''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A series has no play button; it opens''');
        await bddSetUp(tester);
        await iOpenTheLibrary(tester, 'Shows');
        await iRestTheMouseOn(tester, 'Test Show');
        await theCardOfHasNoPlayButton(tester, 'Test Show');
        await iOpen(tester, 'Test Show');
        await iSeeThePageOf(tester, 'Test Show');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A series has no play button; it opens''',
          success,
        );
      }
    });
    testWidgets(
        '''In Prime, a card under the mouse opens a panel after a moment''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In Prime, a card under the mouse opens a panel after a moment''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await iOpenTheLibrary(tester, 'Movies');
        await iRestTheMouseOn(tester, 'Test Movie');
        await afterHalfAMomentNoPanelIsOpen(tester);
        await afterAMomentThePanelOpens(tester);
        await thePanelShows(tester, 'A movie made for tests.');
        await theCardOfIsNotLifted(tester, 'Test Movie');
        await iMoveTheMouseAway(tester);
        await thePanelIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In Prime, a card under the mouse opens a panel after a moment''',
          success,
        );
      }
    });
    testWidgets(
        '''In Prime, the panel marks watched, opens the page, and plays''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In Prime, the panel marks watched, opens the page, and plays''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await iOpenTheLibrary(tester, 'Movies');
        await iRestTheMouseOn(tester, 'Test Movie');
        await afterAMomentThePanelOpens(tester);
        await iTapInThePanel(tester, 'watched');
        await theServerIsToldWasWatched(tester, 'Test Movie');
        await iTapInThePanel(tester, 'details');
        await iSeeThePageOf(tester, 'Test Movie');
        await thePanelIsClosed(tester);
        await iGoBack(tester);
        await iMoveTheMouseAway(tester);
        await iRestTheMouseOn(tester, 'Test Movie');
        await afterAMomentThePanelOpens(tester);
        await iTapInThePanel(tester, 'play');
        await thePlayerIsOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In Prime, the panel marks watched, opens the page, and plays''',
          success,
        );
      }
    });
  });
}
