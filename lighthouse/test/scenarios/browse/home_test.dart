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
import './step/the_latest_items_cannot_be_loaded.dart';
import './step/the_row_says.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry_in_the_row.dart';
import './step/the_list_of_libraries_cannot_be_loaded.dart';
import './step/i_see.dart';
import './step/i_tap_retry.dart';
import './step/i_open.dart';
import './step/i_see_the_library.dart';
import './step/i_go_back.dart';
import './step/i_see_home.dart';

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
    testWidgets('''A row that fails says so, and the others still show''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A row that fails says so, and the others still show''');
        await bddSetUp(tester);
        await theLatestItemsCannotBeLoaded(tester);
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
          '''A row that fails says so, and the others still show''',
          success,
        );
      }
    });
    testWidgets('''Libraries that fail to load can be tried again''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Libraries that fail to load can be tried again''');
        await bddSetUp(tester);
        await theListOfLibrariesCannotBeLoaded(tester);
        await iGoHome(tester);
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSeeInTheRow(tester, 'Movies', 'My media');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Libraries that fail to load can be tried again''',
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
  });
}
