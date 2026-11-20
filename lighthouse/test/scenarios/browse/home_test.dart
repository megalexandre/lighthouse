// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_go_home.dart';
import './step/i_see_in_the_row.dart';
import './step/there_is_no_row.dart';
import './step/is_percent_watched.dart';
import './step/is_next_up.dart';
import './step/the_row_shows_how_much_is_watched.dart';
import './step/there_is_something_in_every_row.dart';
import './step/the_row_cannot_be_loaded.dart';
import './step/the_row_says.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry_in_the_row.dart';
import './step/the_theme_is.dart';
import './step/the_list_of_libraries_cannot_be_loaded.dart';
import './step/i_see.dart';
import './step/i_tap_retry.dart';
import './step/i_see_the_libraries.dart';
import './step/there_are_no_libraries.dart';
import './step/i_pull_home_down.dart';
import './step/i_open.dart';
import './step/i_see_the_library.dart';
import './step/i_go_back.dart';
import './step/i_see_home.dart';
import './step/there_is_no_bar_of_tabs.dart';
import './step/there_is_no_carousel.dart';
import './step/no_row_has_arrows.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Home''', () {
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

    testWidgets('''The libraries, then the latest of each''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The libraries, then the latest of each''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await iSeeInTheRow(tester, 'Shows', 'My media');
        await iSeeInTheRow(tester, 'Music', 'My media');
        await iSeeInTheRow(tester, 'Test Movie', 'Latest in Movies');
        await iSeeInTheRow(tester, 'Test Show', 'Latest in Shows');
        await iSeeInTheRow(tester, 'Test Album', 'Latest in Music');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The libraries, then the latest of each''',
          success,
        );
      }
    });
    testWidgets('''Rows with nothing in them are left out''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Rows with nothing in them are left out''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await thereIsNoRow(tester, 'Continue watching');
        await thereIsNoRow(tester, 'Next up');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Rows with nothing in them are left out''',
          success,
        );
      }
    });
    testWidgets('''What is being watched, and what comes next''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''What is being watched, and what comes next''');
        await bddSetUp(tester);
        await isPercentWatched(tester, 'Test Movie', 40);
        await isNextUp(tester, 'Episode 2');
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Test Movie', 'Continue watching');
        await theRowShowsHowMuchIsWatched(tester, 'Continue watching');
        await iSeeInTheRow(tester, 'Test Show · S1:E2', 'Next up');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''What is being watched, and what comes next''',
          success,
        );
      }
    });
    testWidgets(
        '''A row that fails says so, the others still show, and it can be tried again ('Latest in Movies', 'Test Movie')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A row that fails says so, the others still show, and it can be tried again ('Latest in Movies', 'Test Movie')''');
        await bddSetUp(tester);
        await thereIsSomethingInEveryRow(tester);
        await theRowCannotBeLoaded(tester, 'Latest in Movies');
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await theRowSays(tester, 'Latest in Movies',
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetryInTheRow(tester, 'Latest in Movies');
        await iSeeInTheRow(tester, 'Test Movie', 'Latest in Movies');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A row that fails says so, the others still show, and it can be tried again ('Latest in Movies', 'Test Movie')''',
          success,
        );
      }
    });
    testWidgets(
        '''A row that fails says so, the others still show, and it can be tried again ('Continue watching', 'Test Movie')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A row that fails says so, the others still show, and it can be tried again ('Continue watching', 'Test Movie')''');
        await bddSetUp(tester);
        await thereIsSomethingInEveryRow(tester);
        await theRowCannotBeLoaded(tester, 'Continue watching');
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await theRowSays(tester, 'Continue watching',
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetryInTheRow(tester, 'Continue watching');
        await iSeeInTheRow(tester, 'Test Movie', 'Continue watching');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A row that fails says so, the others still show, and it can be tried again ('Continue watching', 'Test Movie')''',
          success,
        );
      }
    });
    testWidgets(
        '''A row that fails says so, the others still show, and it can be tried again ('Next up', 'Test Show · S1:E2')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A row that fails says so, the others still show, and it can be tried again ('Next up', 'Test Show · S1:E2')''');
        await bddSetUp(tester);
        await thereIsSomethingInEveryRow(tester);
        await theRowCannotBeLoaded(tester, 'Next up');
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await theRowSays(tester, 'Next up',
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetryInTheRow(tester, 'Next up');
        await iSeeInTheRow(tester, 'Test Show · S1:E2', 'Next up');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A row that fails says so, the others still show, and it can be tried again ('Next up', 'Test Show · S1:E2')''',
          success,
        );
      }
    });
    testWidgets(
        '''A row that fails says so, the others still show, and it can be tried again ('Continue reading', 'Test Comic')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A row that fails says so, the others still show, and it can be tried again ('Continue reading', 'Test Comic')''');
        await bddSetUp(tester);
        await thereIsSomethingInEveryRow(tester);
        await theRowCannotBeLoaded(tester, 'Continue reading');
        await iGoHome(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await theRowSays(tester, 'Continue reading',
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetryInTheRow(tester, 'Continue reading');
        await iSeeInTheRow(tester, 'Test Comic', 'Continue reading');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A row that fails says so, the others still show, and it can be tried again ('Continue reading', 'Test Comic')''',
          success,
        );
      }
    });
    testWidgets(
        '''In <theme>, libraries that fail to load can be tried again ('Lanterna')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In <theme>, libraries that fail to load can be tried again ('Lanterna')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Lanterna');
        await theListOfLibrariesCannotBeLoaded(tester);
        await iGoHome(tester);
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSeeTheLibraries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, libraries that fail to load can be tried again ('Lanterna')''',
          success,
        );
      }
    });
    testWidgets(
        '''In <theme>, libraries that fail to load can be tried again ('Prime')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In <theme>, libraries that fail to load can be tried again ('Prime')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await theListOfLibrariesCannotBeLoaded(tester);
        await iGoHome(tester);
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSeeTheLibraries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, libraries that fail to load can be tried again ('Prime')''',
          success,
        );
      }
    });
    testWidgets('''In <theme>, no libraries says so ('Lanterna')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''In <theme>, no libraries says so ('Lanterna')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Lanterna');
        await thereAreNoLibraries(tester);
        await iGoHome(tester);
        await iSee(tester,
            'No libraries yet. Add one on the server, or ask its administrator for access.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, no libraries says so ('Lanterna')''',
          success,
        );
      }
    });
    testWidgets('''In <theme>, no libraries says so ('Prime')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''In <theme>, no libraries says so ('Prime')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await thereAreNoLibraries(tester);
        await iGoHome(tester);
        await iSee(tester,
            'No libraries yet. Add one on the server, or ask its administrator for access.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, no libraries says so ('Prime')''',
          success,
        );
      }
    });
    testWidgets('''In <theme>, pulling home down loads it again ('Lanterna')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In <theme>, pulling home down loads it again ('Lanterna')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Lanterna');
        await iGoHome(tester);
        await isNextUp(tester, 'Episode 2');
        await iPullHomeDown(tester);
        await iSeeInTheRow(tester, 'Test Show · S1:E2', 'Next up');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, pulling home down loads it again ('Lanterna')''',
          success,
        );
      }
    });
    testWidgets('''In <theme>, pulling home down loads it again ('Prime')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In <theme>, pulling home down loads it again ('Prime')''');
        await bddSetUp(tester);
        await theThemeIs(tester, 'Prime');
        await iGoHome(tester);
        await isNextUp(tester, 'Episode 2');
        await iPullHomeDown(tester);
        await iSeeInTheRow(tester, 'Test Show · S1:E2', 'Next up');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In <theme>, pulling home down loads it again ('Prime')''',
          success,
        );
      }
    });
    testWidgets('''A library opens as a grid, and Back returns home''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A library opens as a grid, and Back returns home''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await iOpen(tester, 'Movies');
        await iSeeTheLibrary(tester, 'Movies');
        await iSee(tester, 'Test Movie');
        await iSee(tester, 'HEVC Movie');
        await iGoBack(tester);
        await iSeeHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A library opens as a grid, and Back returns home''',
          success,
        );
      }
    });
    testWidgets('''Lanterna keeps the plain layout''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Lanterna keeps the plain layout''');
        await bddSetUp(tester);
        await iGoHome(tester);
        await thereIsNoBarOfTabs(tester);
        await thereIsNoCarousel(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
        await noRowHasArrows(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Lanterna keeps the plain layout''',
          success,
        );
      }
    });
  });
}
