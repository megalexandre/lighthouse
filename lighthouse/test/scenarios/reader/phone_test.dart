// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_read.dart';
import './step/i_tap_the_middle.dart';
import './step/i_open_the_contents.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_contents_are_closed.dart';
import './step/the_book_is_still_open.dart';
import './step/i_am_back_on_the_books_page.dart';
import './step/the_page_fills_the_screen.dart';
import './step/the_text_of_is_clear_of_the_phones_bars.dart';
import './step/the_picture_is_as_wide_as_the_screen.dart';
import './step/the_lines_of_are_at_most_wide.dart';
import './step/the_bars_are_hidden.dart';
import './step/the_phones_bars_are_hidden.dart';
import './step/i_note_where_the_page_is.dart';
import './step/the_bars_are_shown.dart';
import './step/the_phones_bars_are_shown.dart';
import './step/the_page_is_where_it_was.dart';
import './step/the_book_cannot_be_downloaded.dart';
import './step/the_screen_stays_on.dart';
import './step/the_screen_may_turn_off.dart';
import './step/i_press.dart';
import './step/i_pick_the_page_layout.dart';
import './step/the_reader_shows.dart';
import './step/there_is_no_page_on_the_left.dart';
import './step/there_is_a_page_on_the_left.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Reading on a phone''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await theAppRunsOnA(tester, 'phone');
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Back closes the contents, then leaves the book''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Back closes the contents, then leaves the book''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iTapTheMiddle(tester);
        await iOpenTheContents(tester);
        await iUseThePhonesBack(tester);
        await theContentsAreClosed(tester);
        await theBookIsStillOpen(tester);
        await iUseThePhonesBack(tester);
        await iAmBackOnTheBooksPage(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Back closes the contents, then leaves the book''',
          success,
        );
      }
    });
    testWidgets('''The page is the whole screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The page is the whole screen''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await thePageFillsTheScreen(tester);
        await theTextOfIsClearOfThePhonesBars(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The page is the whole screen''',
          success,
        );
      }
    });
    testWidgets('''A comic's page is the whole screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A comic's page is the whole screen''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await thePageFillsTheScreen(tester);
        await thePictureIsAsWideAsTheScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A comic's page is the whole screen''',
          success,
        );
      }
    });
    testWidgets('''The page is the whole screen on its side''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The page is the whole screen on its side''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone on its side');
        await iRead(tester, 'book-epub');
        await thePageFillsTheScreen(tester);
        await theTextOfIsClearOfThePhonesBars(tester, 'book-epub');
        await theLinesOfAreAtMostWide(tester, 'book-epub', 640);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The page is the whole screen on its side''',
          success,
        );
      }
    });
    testWidgets('''A book opens full screen''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A book opens full screen''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await theBarsAreHidden(tester);
        await thePhonesBarsAreHidden(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A book opens full screen''',
          success,
        );
      }
    });
    testWidgets('''A tap in the middle shows the bars, another hides them''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A tap in the middle shows the bars, another hides them''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iNoteWhereThePageIs(tester);
        await iTapTheMiddle(tester);
        await theBarsAreShown(tester);
        await thePhonesBarsAreShown(tester);
        await thePageIsWhereItWas(tester);
        await iTapTheMiddle(tester);
        await theBarsAreHidden(tester);
        await thePhonesBarsAreHidden(tester);
        await thePageIsWhereItWas(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tap in the middle shows the bars, another hides them''',
          success,
        );
      }
    });
    testWidgets('''A book that cannot be opened leaves the phone's bars''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A book that cannot be opened leaves the phone's bars''');
        await bddSetUp(tester);
        await theBookCannotBeDownloaded(tester);
        await iRead(tester, 'book-comic');
        await thePhonesBarsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A book that cannot be opened leaves the phone's bars''',
          success,
        );
      }
    });
    testWidgets('''Leaving the book gives the phone's bars back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Leaving the book gives the phone's bars back''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await thePhonesBarsAreHidden(tester);
        await iUseThePhonesBack(tester);
        await iAmBackOnTheBooksPage(tester);
        await thePhonesBarsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Leaving the book gives the phone's bars back''',
          success,
        );
      }
    });
    testWidgets('''The screen stays on while a book is open''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The screen stays on while a book is open''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await theScreenStaysOn(tester);
        await iUseThePhonesBack(tester);
        await iAmBackOnTheBooksPage(tester);
        await theScreenMayTurnOff(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The screen stays on while a book is open''',
          success,
        );
      }
    });
    testWidgets('''One page on its side, even when two are asked for''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''One page on its side, even when two are asked for''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone on its side');
        await iRead(tester, 'book-comic');
        await iPress(tester, 'Right');
        await iTapTheMiddle(tester);
        await iPickThePageLayout(tester, 'double');
        await theReaderShows(tester, 'Page 2 of 5');
        await thereIsNoPageOnTheLeft(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''One page on its side, even when two are asked for''',
          success,
        );
      }
    });
    testWidgets('''A tablet shows two pages when asked''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A tablet shows two pages when asked''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'tablet on its side');
        await iRead(tester, 'book-comic');
        await iPress(tester, 'Right');
        await iTapTheMiddle(tester);
        await iPickThePageLayout(tester, 'double');
        await theReaderShows(tester, 'Pages 2–3 of 5');
        await thereIsAPageOnTheLeft(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tablet shows two pages when asked''',
          success,
        );
      }
    });
  });
}
