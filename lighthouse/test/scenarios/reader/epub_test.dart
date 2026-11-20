// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_read.dart';
import './step/the_reader_shows.dart';
import './step/i_turn_the_page_with_the_right_arrow_key.dart';
import './step/i_stop_a_moment.dart';
import './step/the_server_keeps_a_fraction_of.dart';
import './step/i_close_the_book.dart';
import './step/the_server_gives_that_place_back.dart';
import './step/i_read_it_again.dart';
import './step/was_left_halfway.dart';
import './step/the_window_becomes_by.dart';
import './step/i_open_the_contents.dart';
import './step/i_see.dart';
import './step/i_tap.dart';
import './step/the_contents_are_closed.dart';
import './step/i_press.dart';
import './step/i_bookmark_the_page.dart';
import './step/i_see_a_button.dart';
import './step/i_open_the_bookmarks.dart';
import './step/i_tap_the_button.dart';
import './step/i_see_a_line.dart';
import './step/has_no_bookmarks.dart';
import './step/the_desk_is.dart';
import './step/i_pick_the_theme.dart';
import './step/the_paper_is.dart';
import './step/i_close_the_display_settings.dart';
import './step/the_reader_was_set_to_px_sans_serif.dart';
import './step/the_type_of_is_px.dart';
import './step/the_type_of_is_sans_serif.dart';
import './step/i_open_the_display_settings.dart';
import './step/i_make_the_type_bigger.dart';
import './step/i_can_pick_the_theme.dart';
import './step/there_are_no_type_settings.dart';
import './step/a_book_with_a_link_to_a_note_two_pages_on.dart';
import './step/i_follow_the_link.dart';
import './step/i_go_back_from_the_link.dart';
import './step/i_do_not_see.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''EPUB''', () {
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

    testWidgets(
        '''Laid out a page per chapter; the place kept is the fraction read''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Laid out a page per chapter; the place kept is the fraction read''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await theReaderShows(tester, 'Page 1 of 3');
        await iTurnThePageWithTheRightArrowKey(tester);
        await theReaderShows(tester, 'Page 2 of 3');
        await iStopAMoment(tester);
        await theServerKeepsAFractionOf(tester, 'book-epub');
        await iCloseTheBook(tester);
        await theServerGivesThatPlaceBack(tester);
        await iReadItAgain(tester);
        await theReaderShows(tester, 'Page 2 of 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Laid out a page per chapter; the place kept is the fraction read''',
          success,
        );
      }
    });
    testWidgets('''Left halfway, it opens on the middle chapter''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Left halfway, it opens on the middle chapter''');
        await bddSetUp(tester);
        await wasLeftHalfway(tester, 'book-epub');
        await iRead(tester, 'book-epub');
        await theReaderShows(tester, 'Page 2 of 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Left halfway, it opens on the middle chapter''',
          success,
        );
      }
    });
    testWidgets('''Another window size lays it out again, at the same place''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Another window size lays it out again, at the same place''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iTurnThePageWithTheRightArrowKey(tester);
        await theWindowBecomesBy(tester, 900, 1400);
        await theReaderShows(tester, 'Page 2 of 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Another window size lays it out again, at the same place''',
          success,
        );
      }
    });
    testWidgets('''The contents list the chapters, and one jumps there''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The contents list the chapters, and one jumps there''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iOpenTheContents(tester);
        await iSee(tester, 'Chapter One');
        await iSee(tester, 'Chapter Two');
        await iTap(tester, 'Chapter Three');
        await theContentsAreClosed(tester);
        await theReaderShows(tester, 'Page 3 of 3');
        await iPress(tester, 'Left');
        await theReaderShows(tester, 'Page 2 of 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The contents list the chapters, and one jumps there''',
          success,
        );
      }
    });
    testWidgets('''A book without contents says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A book without contents says so''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iOpenTheContents(tester);
        await iSee(tester, 'This book has no table of contents.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A book without contents says so''',
          success,
        );
      }
    });
    testWidgets('''A bookmarked page is kept, listed, and removed''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A bookmarked page is kept, listed, and removed''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iPress(tester, 'Right');
        await iBookmarkThePage(tester);
        await iSeeAButton(tester, 'Remove bookmark');
        await iPress(tester, 'Right');
        await iSeeAButton(tester, 'Bookmark this page');
        await iOpenTheBookmarks(tester);
        await iSee(tester, 'Page 2');
        await iSee(tester, 'Chapter Two');
        await iTap(tester, 'Page 2');
        await theReaderShows(tester, 'Page 2 of 3');
        await iCloseTheBook(tester);
        await iReadItAgain(tester);
        await iOpenTheBookmarks(tester);
        await iTapTheButton(tester, 'Remove bookmark');
        await iSeeALine(tester, 'No bookmarks yet');
        await hasNoBookmarks(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A bookmarked page is kept, listed, and removed''',
          success,
        );
      }
    });
    testWidgets('''The theme changes the desk and the paper, and is kept''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The theme changes the desk and the paper, and is kept''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await theDeskIs(tester, 'light');
        await iPickTheTheme(tester, 'dark');
        await theDeskIs(tester, 'dark');
        await thePaperIs(tester, 'dark');
        await iCloseTheDisplaySettings(tester);
        await iCloseTheBook(tester);
        await iReadItAgain(tester);
        await theDeskIs(tester, 'dark');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The theme changes the desk and the paper, and is kept''',
          success,
        );
      }
    });
    testWidgets('''What was set before applies from the start''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''What was set before applies from the start''');
        await bddSetUp(tester);
        await theReaderWasSetToPxSansSerif(tester, 'sepia', 24);
        await iRead(tester, 'book-epub');
        await theDeskIs(tester, 'sepia');
        await theTypeOfIsPx(tester, 'book-epub', 24);
        await theTypeOfIsSansSerif(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''What was set before applies from the start''',
          success,
        );
      }
    });
    testWidgets('''Bigger type lays the book out again, at the same place''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Bigger type lays the book out again, at the same place''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iPress(tester, 'Right');
        await iOpenTheDisplaySettings(tester);
        await iSee(tester, '18 px');
        await iMakeTheTypeBigger(tester);
        await iMakeTheTypeBigger(tester);
        await iSee(tester, '22 px');
        await theTypeOfIsPx(tester, 'book-epub', 22);
        await theReaderShows(tester, 'Page 2 of 3');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Bigger type lays the book out again, at the same place''',
          success,
        );
      }
    });
    testWidgets('''A comic has the themes, but no type settings''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A comic has the themes, but no type settings''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iOpenTheDisplaySettings(tester);
        await iCanPickTheTheme(tester, 'sepia');
        await thereAreNoTypeSettings(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A comic has the themes, but no type settings''',
          success,
        );
      }
    });
    testWidgets('''A link goes to its target, and back''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A link goes to its target, and back''');
        await bddSetUp(tester);
        await aBookWithALinkToANoteTwoPagesOn(tester, 'book-links');
        await iRead(tester, 'book-links');
        await theReaderShows(tester, 'Page 1 of 3');
        await iFollowTheLink(tester);
        await theReaderShows(tester, 'Page 3 of 3');
        await iSee(tester, 'Back to page 1');
        await iGoBackFromTheLink(tester);
        await theReaderShows(tester, 'Page 1 of 3');
        await iDoNotSee(tester, 'Back to page 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A link goes to its target, and back''',
          success,
        );
      }
    });
  });
}
