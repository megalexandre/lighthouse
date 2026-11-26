// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_window_is_by.dart';
import './step/i_read.dart';
import './step/i_press.dart';
import './step/the_window_is_full_screen.dart';
import './step/the_bars_are_hidden.dart';
import './step/the_page_fills_the_screen.dart';
import './step/the_lines_of_are_at_most_wide.dart';
import './step/the_window_is_not_full_screen.dart';
import './step/the_bars_are_shown.dart';
import './step/the_book_is_still_open.dart';
import './step/i_am_back_on_the_books_page.dart';
import './step/i_tap_the_full_screen_button.dart';
import './step/i_tap_the_middle.dart';
import './step/i_close_the_book.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Full screen with a mouse''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await theWindowIsBy(tester, 1000, 1200);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''F11 makes the page the whole screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''F11 makes the page the whole screen''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iPress(tester, 'F11');
        await theWindowIsFullScreen(tester);
        await theBarsAreHidden(tester);
        await thePageFillsTheScreen(tester);
        await theLinesOfAreAtMostWide(tester, 'book-epub', 640);
        await iPress(tester, 'F11');
        await theWindowIsNotFullScreen(tester);
        await theBarsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''F11 makes the page the whole screen''',
          success,
        );
      }
    });
    testWidgets('''Esc leaves full screen, then the book''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Esc leaves full screen, then the book''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iPress(tester, 'F');
        await theWindowIsFullScreen(tester);
        await iPress(tester, 'Esc');
        await theWindowIsNotFullScreen(tester);
        await theBookIsStillOpen(tester);
        await iPress(tester, 'Esc');
        await iAmBackOnTheBooksPage(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Esc leaves full screen, then the book''',
          success,
        );
      }
    });
    testWidgets('''The button goes full screen, a click brings the bars back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The button goes full screen, a click brings the bars back''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTapTheFullScreenButton(tester);
        await theWindowIsFullScreen(tester);
        await theBarsAreHidden(tester);
        await thePageFillsTheScreen(tester);
        await iTapTheMiddle(tester);
        await theBarsAreShown(tester);
        await theWindowIsFullScreen(tester);
        await iTapTheFullScreenButton(tester);
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The button goes full screen, a click brings the bars back''',
          success,
        );
      }
    });
    testWidgets('''Leaving the book leaves full screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Leaving the book leaves full screen''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iPress(tester, 'F');
        await iTapTheMiddle(tester);
        await iCloseTheBook(tester);
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Leaving the book leaves full screen''',
          success,
        );
      }
    });
  });
}
