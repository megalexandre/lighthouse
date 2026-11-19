// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_open_the_library.dart';
import './step/i_see_the_library.dart';
import './step/i_see.dart';
import './step/there_are_movies.dart';
import './step/i_do_not_see.dart';
import './step/i_scroll_to_the_end.dart';
import './step/nothing_is_loading.dart';
import './step/the_library_cannot_be_loaded.dart';
import './step/the_server_answers_again.dart';
import './step/i_tap_retry.dart';
import './step/i_open.dart';
import './step/i_see_the_page_of.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Library''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(
      String title,
      bool success, [
      List<String>? tags,
    ]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''The library's name and its items''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The library's name and its items''');
        await bddSetUp(tester);
        await iOpenTheLibrary(tester, 'Movies');
        await iSeeTheLibrary(tester, 'Movies');
        await iSee(tester, 'Test Movie');
        await iSee(tester, '2020');
        await iSee(tester, 'HEVC Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''The library's name and its items''', success);
      }
    });
    testWidgets('''Scrolling to the end brings every item''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Scrolling to the end brings every item''');
        await bddSetUp(tester);
        await thereAreMovies(tester, 250);
        await iOpenTheLibrary(tester, 'Movies');
        await iDoNotSee(tester, 'Movie 249');
        await iScrollToTheEnd(tester);
        await iSee(tester, 'Movie 249');
        await nothingIsLoading(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''Scrolling to the end brings every item''', success);
      }
    });
    testWidgets('''A page that fails to load can be tried again''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A page that fails to load can be tried again''');
        await bddSetUp(tester);
        await thereAreMovies(tester, 150);
        await iOpenTheLibrary(tester, 'Movies');
        await theLibraryCannotBeLoaded(tester);
        await iScrollToTheEnd(tester);
        await iDoNotSee(tester, 'Movie 149');
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iScrollToTheEnd(tester);
        await iSee(tester, 'Movie 149');
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
    testWidgets('''An empty library says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An empty library says so''');
        await bddSetUp(tester);
        await thereAreMovies(tester, 0);
        await iOpenTheLibrary(tester, 'Movies');
        await iSee(tester, 'Nothing here yet.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''An empty library says so''', success);
      }
    });
    testWidgets('''A library that fails to open can be tried again''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A library that fails to open can be tried again''');
        await bddSetUp(tester);
        await theLibraryCannotBeLoaded(tester);
        await iOpenTheLibrary(tester, 'Movies');
        await iSee(
          tester,
          'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.',
        );
        await theServerAnswersAgain(tester);
        await iTapRetry(tester);
        await iSee(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A library that fails to open can be tried again''',
          success,
        );
      }
    });
    testWidgets('''A movie opens its page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie opens its page''');
        await bddSetUp(tester);
        await iOpenTheLibrary(tester, 'Movies');
        await iOpen(tester, 'Test Movie');
        await iSeeThePageOf(tester, 'Test Movie');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''A movie opens its page''', success);
      }
    });
  });
}
