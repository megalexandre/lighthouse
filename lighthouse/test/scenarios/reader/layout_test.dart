// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_window_is_by.dart';
import './step/i_read.dart';
import './step/the_reader_shows.dart';
import './step/there_is_no_page_on_the_left.dart';
import './step/i_press.dart';
import './step/there_is_a_page_on_the_left.dart';
import './step/i_stop_a_moment.dart';
import './step/the_server_has_as_read.dart';
import './step/each_page_is_at_most_half_the_window_wide.dart';
import './step/i_pick_the_page_layout.dart';
import './step/i_close_the_book.dart';
import './step/i_read_it_again.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Page layout''', () {
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

    testWidgets('''A wide window shows two pages, the cover alone''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A wide window shows two pages, the cover alone''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 1600, 1000);
        await iRead(tester, 'book-comic');
        await theReaderShows(tester, 'Page 1 of 5');
        await thereIsNoPageOnTheLeft(tester);
        await iPress(tester, 'Right');
        await theReaderShows(tester, 'Pages 2–3 of 5');
        await thereIsAPageOnTheLeft(tester);
        await iPress(tester, 'Left');
        await theReaderShows(tester, 'Page 1 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A wide window shows two pages, the cover alone''',
          success,
        );
      }
    });
    testWidgets('''The last spread marks the book read''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The last spread marks the book read''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 1600, 1000);
        await iRead(tester, 'book-comic');
        await iPress(tester, 'End');
        await theReaderShows(tester, 'Pages 4–5 of 5');
        await iPress(tester, 'Left');
        await iPress(tester, 'Right');
        await iStopAMoment(tester);
        await theServerHasAsRead(tester, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The last spread marks the book read''',
          success,
        );
      }
    });
    testWidgets('''An EPUB is laid out for half the window''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An EPUB is laid out for half the window''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 1600, 1000);
        await iRead(tester, 'book-epub');
        await eachPageIsAtMostHalfTheWindowWide(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An EPUB is laid out for half the window''',
          success,
        );
      }
    });
    testWidgets('''A narrow window shows one page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A narrow window shows one page''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 800, 600);
        await iRead(tester, 'book-comic');
        await iPress(tester, 'Right');
        await theReaderShows(tester, 'Page 2 of 5');
        await thereIsNoPageOnTheLeft(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A narrow window shows one page''',
          success,
        );
      }
    });
    testWidgets('''Two pages when asked, however narrow the window''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Two pages when asked, however narrow the window''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 800, 600);
        await iRead(tester, 'book-comic');
        await iPress(tester, 'Right');
        await iPickThePageLayout(tester, 'double');
        await theReaderShows(tester, 'Pages 2–3 of 5');
        await thereIsAPageOnTheLeft(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Two pages when asked, however narrow the window''',
          success,
        );
      }
    });
    testWidgets('''One page when asked, however wide the window, and kept''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''One page when asked, however wide the window, and kept''');
        await bddSetUp(tester);
        await theWindowIsBy(tester, 1600, 1000);
        await iRead(tester, 'book-comic');
        await iPickThePageLayout(tester, 'single');
        await iPress(tester, 'Right');
        await theReaderShows(tester, 'Page 2 of 5');
        await iCloseTheBook(tester);
        await iReadItAgain(tester);
        await iPress(tester, 'Right');
        await thereIsNoPageOnTheLeft(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''One page when asked, however wide the window, and kept''',
          success,
        );
      }
    });
  });
}
