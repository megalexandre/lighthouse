// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_am_on_the_home_screen.dart';
import './step/i_tap_the_search_button.dart';
import './step/i_see_the_search_screen.dart';
import './step/i_press_ctrlf.dart';
import './step/i_am_on_the_search_screen.dart';
import './step/i_search_for.dart';
import './step/i_see_among_the.dart';
import './step/there_is_no_row.dart';
import './step/i_see.dart';
import './step/i_open.dart';
import './step/i_see_the_page_of.dart';
import './step/the_server_cannot_be_reached.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Search''', () {
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

    testWidgets('''The search button opens search''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The search button opens search''');
        await bddSetUp(tester);
        await iAmOnTheHomeScreen(tester);
        await iTapTheSearchButton(tester);
        await iSeeTheSearchScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The search button opens search''',
          success,
        );
      }
    });
    testWidgets('''Ctrl+F opens search''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Ctrl+F opens search''');
        await bddSetUp(tester);
        await iAmOnTheHomeScreen(tester);
        await iPressCtrlf(tester);
        await iSeeTheSearchScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Ctrl+F opens search''',
          success,
        );
      }
    });
    testWidgets('''Results come in rows by kind''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Results come in rows by kind''');
        await bddSetUp(tester);
        await iAmOnTheSearchScreen(tester);
        await iSearchFor(tester, 'test');
        await iSeeAmongThe(tester, 'Test Movie', 'Movies');
        await iSeeAmongThe(tester, 'Test Show', 'Shows');
        await iSeeAmongThe(tester, 'Test Album', 'Albums');
        await thereIsNoRow(tester, 'Songs');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Results come in rows by kind''',
          success,
        );
      }
    });
    testWidgets('''A search that finds nothing says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A search that finds nothing says so''');
        await bddSetUp(tester);
        await iAmOnTheSearchScreen(tester);
        await iSearchFor(tester, 'zzz');
        await iSee(tester, 'Nothing found for "zzz".');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A search that finds nothing says so''',
          success,
        );
      }
    });
    testWidgets('''A result opens its page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A result opens its page''');
        await bddSetUp(tester);
        await iAmOnTheSearchScreen(tester);
        await iSearchFor(tester, 'movie');
        await iOpen(tester, 'Test Movie');
        await iSeeThePageOf(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A result opens its page''',
          success,
        );
      }
    });
    testWidgets('''A search that fails can be tried again''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A search that fails can be tried again''');
        await bddSetUp(tester);
        await theServerCannotBeReached(tester);
        await iAmOnTheSearchScreen(tester);
        await iSearchFor(tester, 'test');
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSeeAmongThe(tester, 'Test Movie', 'Movies');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A search that fails can be tried again''',
          success,
        );
      }
    });
  });
}
