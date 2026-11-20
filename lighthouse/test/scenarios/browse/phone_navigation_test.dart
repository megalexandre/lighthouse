// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_go_home.dart';
import './step/the_navigation_is_a_bar_below.dart';
import './step/the_top_bar_shows_only_the_mark.dart';
import './step/the_navigation_is_a_rail_at_the_left.dart';
import './step/i_tap_in_the_navigation.dart';
import './step/i_see_the_list_of_libraries.dart';
import './step/i_open.dart';
import './step/the_top_bar_is_titled.dart';
import './step/is_on_in_the_navigation.dart';
import './step/i_see_home.dart';
import './step/i_see_the_search_page.dart';
import './step/the_profile_sheet_names.dart';
import './step/i_tap_in_the_profile_sheet.dart';
import './step/i_see_settings.dart';
import './step/the_profile_sheet_is_closed.dart';
import './step/i_see_the_login_screen.dart';
import './step/the_theme_is.dart';
import './step/there_is_no_navigation_bar_or_rail.dart';
import './step/there_is_a_tab_for_each_library.dart';
import './step/i_open_the_page_of.dart';
import './step/i_use_the_phones_back.dart';
import './step/i_open_the_search_field.dart';
import './step/there_is_no_search_field.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Navigation on a phone''', () {
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

    testWidgets('''A phone has a bar below and only the mark above''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A phone has a bar below and only the mark above''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await theNavigationIsABarBelow(tester);
        await theTopBarShowsOnlyTheMark(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A phone has a bar below and only the mark above''',
          success,
        );
      }
    });
    testWidgets('''On its side, the navigation is a rail at the left''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On its side, the navigation is a rail at the left''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone on its side');
        await iGoHome(tester);
        await theNavigationIsARailAtTheLeft(tester);
        await iTapInTheNavigation(tester, 'Libraries');
        await iSeeTheListOfLibraries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On its side, the navigation is a rail at the left''',
          success,
        );
      }
    });
    testWidgets(
        '''Libraries lists them, and one opens with Libraries still on''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Libraries lists them, and one opens with Libraries still on''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapInTheNavigation(tester, 'Libraries');
        await iSeeTheListOfLibraries(tester);
        await iOpen(tester, 'Movies');
        await theTopBarIsTitled(tester, 'Movies');
        await isOnInTheNavigation(tester, 'Libraries');
        await iTapInTheNavigation(tester, 'Home');
        await iSeeHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Libraries lists them, and one opens with Libraries still on''',
          success,
        );
      }
    });
    testWidgets('''Search opens the search page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Search opens the search page''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapInTheNavigation(tester, 'Search');
        await iSeeTheSearchPage(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Search opens the search page''',
          success,
        );
      }
    });
    testWidgets('''The profile names who is signed in, and opens Settings''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The profile names who is signed in, and opens Settings''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapInTheNavigation(tester, 'Profile');
        await theProfileSheetNames(tester, 'alice');
        await iTapInTheProfileSheet(tester, 'Settings');
        await iSeeSettings(tester);
        await theProfileSheetIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The profile names who is signed in, and opens Settings''',
          success,
        );
      }
    });
    testWidgets('''Signing out from the profile sheet''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Signing out from the profile sheet''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapInTheNavigation(tester, 'Profile');
        await iTapInTheProfileSheet(tester, 'Sign out');
        await iSeeTheLoginScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Signing out from the profile sheet''',
          success,
        );
      }
    });
    testWidgets('''The desktop keeps the tabs in the top bar''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''The desktop keeps the tabs in the top bar''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await iGoHome(tester);
        await thereIsNoNavigationBarOrRail(tester);
        await thereIsATabForEachLibrary(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The desktop keeps the tabs in the top bar''',
          success,
        );
      }
    });
    testWidgets('''Back leaves a page for the one before''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Back leaves a page for the one before''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iOpenThePageOf(tester, 'Test Movie');
        await iUseThePhonesBack(tester);
        await iSeeHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Back leaves a page for the one before''',
          success,
        );
      }
    });
    testWidgets('''Back leaves the search page opened from the bar below''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Back leaves the search page opened from the bar below''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iGoHome(tester);
        await iTapInTheNavigation(tester, 'Search');
        await iUseThePhonesBack(tester);
        await iSeeHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Back leaves the search page opened from the bar below''',
          success,
        );
      }
    });
    testWidgets(
        '''On a tablet on its side, Back closes the search field first''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a tablet on its side, Back closes the search field first''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'tablet on its side');
        await iGoHome(tester);
        await iOpenTheSearchField(tester);
        await iUseThePhonesBack(tester);
        await thereIsNoSearchField(tester);
        await iSeeHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a tablet on its side, Back closes the search field first''',
          success,
        );
      }
    });
  });
}
