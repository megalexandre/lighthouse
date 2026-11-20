// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_open_the_library.dart';
import './step/i_longpress.dart';
import './step/the_cards_actions_are_open.dart';
import './step/i_tap_in_the_cards_actions.dart';
import './step/the_cards_actions_are_closed.dart';
import './step/the_player_is_open.dart';
import './step/the_server_is_told_was_watched.dart';
import './step/i_see_the_page_of.dart';
import './step/the_theme_is.dart';
import './step/i_go_home.dart';
import './step/the_carousel_shows.dart';
import './step/i_swipe_the_carousel_to_the.dart';
import './step/i_drag_the_carousel_slowly_a_little_to_the_left.dart';
import './step/i_tap_the_dot_of_the_carousel.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Touch''', () {
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

    testWidgets('''A long press on a card opens its actions, which play''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A long press on a card opens its actions, which play''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iOpenTheLibrary(tester, 'Movies');
        await iLongpress(tester, 'Test Movie');
        await theCardsActionsAreOpen(tester);
        await iTapInTheCardsActions(tester, 'play');
        await theCardsActionsAreClosed(tester);
        await thePlayerIsOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A long press on a card opens its actions, which play''',
          success,
        );
      }
    });
    testWidgets('''The card's actions mark it watched''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The card's actions mark it watched''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iOpenTheLibrary(tester, 'Movies');
        await iLongpress(tester, 'Test Movie');
        await iTapInTheCardsActions(tester, 'watched');
        await theServerIsToldWasWatched(tester, 'Test Movie');
        await theCardsActionsAreClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The card's actions mark it watched''',
          success,
        );
      }
    });
    testWidgets('''The card's actions open the details''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The card's actions open the details''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iOpenTheLibrary(tester, 'Movies');
        await iLongpress(tester, 'Test Movie');
        await iTapInTheCardsActions(tester, 'details');
        await iSeeThePageOf(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The card's actions open the details''',
          success,
        );
      }
    });
    testWidgets('''On the desktop a long press opens nothing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''On the desktop a long press opens nothing''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await iOpenTheLibrary(tester, 'Movies');
        await iLongpress(tester, 'Test Movie');
        await theCardsActionsAreClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On the desktop a long press opens nothing''',
          success,
        );
      }
    });
    testWidgets(
        '''A swipe to the left shows the next slide, to the right the one before''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A swipe to the left shows the next slide, to the right the one before''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await theCarouselShows(tester, 'Test Movie');
        await iSwipeTheCarouselToThe(tester, 'left');
        await theCarouselShows(tester, 'HEVC Movie');
        await iSwipeTheCarouselToThe(tester, 'right');
        await theCarouselShows(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A swipe to the left shows the next slide, to the right the one before''',
          success,
        );
      }
    });
    testWidgets('''A slow drag does not change the slide''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A slow drag does not change the slide''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iDragTheCarouselSlowlyALittleToTheLeft(tester);
        await theCarouselShows(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A slow drag does not change the slide''',
          success,
        );
      }
    });
    testWidgets('''The carousel's dots take no taps''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The carousel's dots take no taps''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapTheDotOfTheCarousel(tester, 2);
        await theCarouselShows(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The carousel's dots take no taps''',
          success,
        );
      }
    });
  });
}
