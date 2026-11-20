// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_theme_is.dart';
import './step/i_go_home.dart';
import './step/there_is_a_tab_for_each_library.dart';
import './step/there_is_no_row.dart';
import './step/the_carousel_shows.dart';
import './step/the_bar_is_seethrough.dart';
import './step/no_library_tab_is_on.dart';
import './step/i_tap_the_arrow_of_the_carousel.dart';
import './step/i_tap_the_dot_of_the_carousel.dart';
import './step/the_carousel_offers.dart';
import './step/i_wait_for_the_carousel_to_move_on.dart';
import './step/i_tap_the_button_of_the_carousel.dart';
import './step/i_see_the_page_of.dart';
import './step/i_go_back.dart';
import './step/the_player_is_open.dart';
import './step/i_tap_the_tab.dart';
import './step/the_tab_is_on.dart';
import './step/the_bar_is_solid.dart';
import './step/i_see.dart';
import './step/i_scroll_home_down.dart';
import './step/there_is_no_search_field.dart';
import './step/i_search_the_bar_for.dart';
import './step/the_search_screen_searches_for.dart';
import './step/i_pick_in_the_profile_menu.dart';
import './step/home_is.dart';
import './step/i_see_settings.dart';
import './step/i_see_the_login_screen.dart';
import './step/there_are_movies.dart';
import './step/i_scroll_to_the_row.dart';
import './step/the_row_has_a_arrow.dart';
import './step/the_row_has_no_arrow.dart';
import './step/i_tap_the_arrow_of_the_row.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Prime layout''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await theThemeIs(tester, 'Prime');
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''Home has a tab per library and the carousel, no libraries row''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Home has a tab per library and the carousel, no libraries row''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await thereIsATabForEachLibrary(tester);
        await thereIsNoRow(tester, 'My media');
        await theCarouselShows(tester, 'Test Movie');
        await theBarIsSeethrough(tester);
        await noLibraryTabIsOn(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Home has a tab per library and the carousel, no libraries row''',
          success,
        );
      }
    });
    testWidgets('''The carousel moves by its arrows, its dots, and by itself''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The carousel moves by its arrows, its dots, and by itself''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iTapTheArrowOfTheCarousel(tester, 'next');
        await theCarouselShows(tester, 'HEVC Movie');
        await iTapTheArrowOfTheCarousel(tester, 'previous');
        await theCarouselShows(tester, 'Test Movie');
        await iTapTheDotOfTheCarousel(tester, 3);
        await theCarouselShows(tester, 'Test Show');
        await theCarouselOffers(tester, 'Episodes');
        await iWaitForTheCarouselToMoveOn(tester);
        await theCarouselShows(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The carousel moves by its arrows, its dots, and by itself''',
          success,
        );
      }
    });
    testWidgets('''The carousel plays a movie, or opens it''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The carousel plays a movie, or opens it''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iTapTheButtonOfTheCarousel(tester, 'info');
        await iSeeThePageOf(tester, 'Test Movie');
        await iGoBack(tester);
        await iTapTheButtonOfTheCarousel(tester, 'play');
        await thePlayerIsOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The carousel plays a movie, or opens it''',
          success,
        );
      }
    });
    testWidgets(
        '''A tab opens its library under the bar, and Home comes back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A tab opens its library under the bar, and Home comes back''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iTapTheTab(tester, 'Movies');
        await theTabIsOn(tester, 'Movies');
        await theBarIsSolid(tester);
        await iSee(tester, 'Test Movie');
        await iTapTheTab(tester, 'Home');
        await theCarouselShows(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tab opens its library under the bar, and Home comes back''',
          success,
        );
      }
    });
    testWidgets('''Scrolled down, the bar turns solid''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Scrolled down, the bar turns solid''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iScrollHomeDown(tester);
        await theBarIsSolid(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Scrolled down, the bar turns solid''',
          success,
        );
      }
    });
    testWidgets('''Search opens into a field, and Enter searches''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Search opens into a field, and Enter searches''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await thereIsNoSearchField(tester);
        await iSearchTheBarFor(tester, 'test');
        await theSearchScreenSearchesFor(tester, 'test');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Search opens into a field, and Enter searches''',
          success,
        );
      }
    });
    testWidgets(
        '''The profile menu switches the mode, opens Settings, signs out''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The profile menu switches the mode, opens Settings, signs out''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iPickInTheProfileMenu(tester, 'the other mode');
        await homeIs(tester, 'light');
        await iPickInTheProfileMenu(tester, 'Settings');
        await iSeeSettings(tester);
        await iGoBack(tester);
        await iPickInTheProfileMenu(tester, 'Sign out');
        await iSeeTheLoginScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The profile menu switches the mode, opens Settings, signs out''',
          success,
        );
      }
    });
    testWidgets(
        '''A long row pages with arrows, each only where there is more''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A long row pages with arrows, each only where there is more''');
        await bddSetUp(tester);
        await thereAreMovies(tester, 24);
        await iGoHome(tester);
        await iScrollToTheRow(tester, 'Latest in Movies');
        await theRowHasAArrow(tester, 'Latest in Movies', 'next');
        await theRowHasNoArrow(tester, 'Latest in Movies', 'previous');
        await iTapTheArrowOfTheRow(tester, 'next', 'Latest in Movies');
        await theRowHasAArrow(tester, 'Latest in Movies', 'previous');
        await iTapTheArrowOfTheRow(tester, 'previous', 'Latest in Movies');
        await theRowHasNoArrow(tester, 'Latest in Movies', 'previous');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A long row pages with arrows, each only where there is more''',
          success,
        );
      }
    });
  });
}
