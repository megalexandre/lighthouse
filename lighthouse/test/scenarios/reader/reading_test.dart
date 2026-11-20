// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_open_the_page_of.dart';
import './step/i_see.dart';
import './step/i_read_it.dart';
import './step/the_reader_shows.dart';
import './step/was_left_on_page_at_percent.dart';
import './step/i_read.dart';
import './step/i_swipe_to_the_next_page.dart';
import './step/i_stop_a_moment.dart';
import './step/the_server_is_told_only_page_of.dart';
import './step/i_turn_the_page_with_the_right_arrow_key.dart';
import './step/the_server_has_not_been_told_the_place.dart';
import './step/i_press.dart';
import './step/i_tap_the_edge.dart';
import './step/i_drag_the_page_bar_to_the_end.dart';
import './step/the_bars_are_shown.dart';
import './step/i_tap_the_middle.dart';
import './step/the_bars_are_hidden.dart';
import './step/i_go_to_the_last_page.dart';
import './step/the_server_keeps_page_of.dart';
import './step/the_server_has_as_read.dart';
import './step/i_close_the_book.dart';
import './step/i_am_back_on_the_books_page.dart';
import './step/the_book_cannot_be_downloaded.dart';
import './step/i_tap.dart';
import './step/the_server_is_back.dart';
import './step/i_tap_retry.dart';
import './step/i_see_a_button.dart';
import './step/i_mark_it_read.dart';
import './step/is_percent_read.dart';
import './step/i_open_the_library.dart';
import './step/i_go_home.dart';
import './step/i_see_in_the_row.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Reading''', () {
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

    testWidgets('''A new book opens on its first page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A new book opens on its first page''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'book-comic');
        await iSee(tester, 'Read');
        await iReadIt(tester);
        await theReaderShows(tester, 'Page 1 of 5');
        await iSee(tester, 'Test Comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A new book opens on its first page''',
          success,
        );
      }
    });
    testWidgets('''A started book opens where it was left''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A started book opens where it was left''');
        await bddSetUp(tester);
        await wasLeftOnPageAtPercent(tester, 'book-comic', 3, 40);
        await iOpenThePageOf(tester, 'book-comic');
        await iSee(tester, 'Continue reading · 40%');
        await iReadIt(tester);
        await theReaderShows(tester, 'Page 3 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A started book opens where it was left''',
          success,
        );
      }
    });
    testWidgets('''A swipe turns the page, and the place is saved''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A swipe turns the page, and the place is saved''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iSwipeToTheNextPage(tester);
        await theReaderShows(tester, 'Page 2 of 5');
        await iStopAMoment(tester);
        await theServerIsToldOnlyPageOf(tester, 2, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A swipe turns the page, and the place is saved''',
          success,
        );
      }
    });
    testWidgets(
        '''Pages turned quickly are saved once, where the reader stops''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Pages turned quickly are saved once, where the reader stops''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iTurnThePageWithTheRightArrowKey(tester);
        await theServerHasNotBeenToldThePlace(tester);
        await iStopAMoment(tester);
        await theReaderShows(tester, 'Page 3 of 5');
        await theServerIsToldOnlyPageOf(tester, 3, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Pages turned quickly are saved once, where the reader stops''',
          success,
        );
      }
    });
    testWidgets('''Keys and the screen's edges turn pages; Home and End jump''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Keys and the screen's edges turn pages; Home and End jump''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await theReaderShows(tester, 'Page 2 of 5');
        await iPress(tester, 'End');
        await theReaderShows(tester, 'Page 5 of 5');
        await iPress(tester, 'Home');
        await theReaderShows(tester, 'Page 1 of 5');
        await iTapTheEdge(tester, 'right');
        await theReaderShows(tester, 'Page 2 of 5');
        await iTapTheEdge(tester, 'left');
        await theReaderShows(tester, 'Page 1 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Keys and the screen's edges turn pages; Home and End jump''',
          success,
        );
      }
    });
    testWidgets('''The page bar goes to a page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The page bar goes to a page''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iDragThePageBarToTheEnd(tester);
        await theReaderShows(tester, 'Page 5 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The page bar goes to a page''',
          success,
        );
      }
    });
    testWidgets('''A tap in the middle hides and shows the bars''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A tap in the middle hides and shows the bars''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await theBarsAreShown(tester);
        await iTapTheMiddle(tester);
        await theBarsAreHidden(tester);
        await iTapTheMiddle(tester);
        await theBarsAreShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tap in the middle hides and shows the bars''',
          success,
        );
      }
    });
    testWidgets('''The last page marks the book read''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The last page marks the book read''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iGoToTheLastPage(tester);
        await iStopAMoment(tester);
        await theServerKeepsPageOf(tester, 5, 'book-comic');
        await theServerHasAsRead(tester, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The last page marks the book read''',
          success,
        );
      }
    });
    testWidgets('''Leaving saves at once, and returns to the book's page''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Leaving saves at once, and returns to the book's page''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iCloseTheBook(tester);
        await theServerIsToldOnlyPageOf(tester, 2, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Leaving saves at once, and returns to the book's page''',
          success,
        );
      }
    });
    testWidgets('''<key> leaves too, and saves at once ('Esc')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''<key> leaves too, and saves at once ('Esc')''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iPress(tester, 'Esc');
        await iAmBackOnTheBooksPage(tester);
        await theServerIsToldOnlyPageOf(tester, 2, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''<key> leaves too, and saves at once ('Esc')''',
          success,
        );
      }
    });
    testWidgets('''<key> leaves too, and saves at once ('Backspace')''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''<key> leaves too, and saves at once ('Backspace')''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iPress(tester, 'Backspace');
        await iAmBackOnTheBooksPage(tester);
        await theServerIsToldOnlyPageOf(tester, 2, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''<key> leaves too, and saves at once ('Backspace')''',
          success,
        );
      }
    });
    testWidgets('''A download that fails can be tried again''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A download that fails can be tried again''');
        await bddSetUp(tester);
        await theBookCannotBeDownloaded(tester);
        await iOpenThePageOf(tester, 'book-comic');
        await iTap(tester, 'Read');
        await iSee(tester,
            'Cannot reach http://jellyfin.test:8096. Check the address and that the server is running.');
        await theServerIsBack(tester);
        await iTapRetry(tester);
        await theReaderShows(tester, 'Page 1 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A download that fails can be tried again''',
          success,
        );
      }
    });
    testWidgets('''A book can be marked read from its page''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A book can be marked read from its page''');
        await bddSetUp(tester);
        await iOpenThePageOf(tester, 'book-comic');
        await iSeeAButton(tester, 'Mark as read');
        await iMarkItRead(tester);
        await theServerHasAsRead(tester, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A book can be marked read from its page''',
          success,
        );
      }
    });
    testWidgets(
        '''The Books library is a grid of books, with how much is read''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The Books library is a grid of books, with how much is read''');
        await bddSetUp(tester);
        await isPercentRead(tester, 'book-comic', 60);
        await iOpenTheLibrary(tester, 'view-books');
        await iSee(tester, 'Test Comic');
        await iSee(tester, '60% read');
        await iSee(tester, 'Test Book');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The Books library is a grid of books, with how much is read''',
          success,
        );
      }
    });
    testWidgets('''Home continues reading, with how much is read''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Home continues reading, with how much is read''');
        await bddSetUp(tester);
        await isPercentRead(tester, 'book-comic', 40);
        await iGoHome(tester);
        await iSeeInTheRow(tester, '40% read', 'Continue reading');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Home continues reading, with how much is read''',
          success,
        );
      }
    });
  });
}
