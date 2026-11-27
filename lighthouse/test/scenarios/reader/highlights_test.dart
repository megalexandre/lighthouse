// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_reader_shows_one_page_at_a_time.dart';
import './step/i_read.dart';
import './step/i_hold_the_word.dart';
import './step/i_see.dart';
import './step/i_highlight_it.dart';
import './step/i_do_not_see.dart';
import './step/is_highlighted.dart';
import './step/i_close_the_book.dart';
import './step/i_read_it_again.dart';
import './step/i_open_the_notes.dart';
import './step/i_drag_the_mouse_from_to.dart';
import './step/the_reader_shows.dart';
import './step/i_copy_it.dart';
import './step/the_clipboard_holds.dart';
import './step/has_no_highlights.dart';
import './step/i_tap.dart';
import './step/i_write_the_note.dart';
import './step/has_the_note.dart';
import './step/i_tap_the_word.dart';
import './step/i_press.dart';
import './step/the_book_is_still_open.dart';
import './step/i_tap_the_button.dart';
import './step/i_see_a_line.dart';
import './step/i_open_the_contents.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Highlights and notes''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await theReaderShowsOnePageAtATime(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''A word held is selected; a colour highlights it, kept for next time''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A word held is selected; a colour highlights it, kept for next time''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iHoldTheWord(tester, 'first');
        await iSee(tester, 'Add note');
        await iHighlightIt(tester, 'red');
        await iDoNotSee(tester, 'Add note');
        await isHighlighted(tester, 'first', 'red');
        await iCloseTheBook(tester);
        await iReadItAgain(tester);
        await iOpenTheNotes(tester);
        await iSee(tester, 'first');
        await iSee(tester, 'Page 1');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A word held is selected; a colour highlights it, kept for next time''',
          success,
        );
      }
    });
    testWidgets(
        '''A mouse dragged over text selects it, without turning the page''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A mouse dragged over text selects it, without turning the page''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iDragTheMouseFromTo(tester, 'first', 'novel');
        await iSee(tester, 'Copy');
        await theReaderShows(tester, 'Page 1 of 3');
        await iCopyIt(tester);
        await theClipboardHolds(tester, 'first chapter of the test novel');
        await iSee(tester, 'Text copied');
        await hasNoHighlights(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A mouse dragged over text selects it, without turning the page''',
          success,
        );
      }
    });
    testWidgets('''A note highlights the passage in yellow''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A note highlights the passage in yellow''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iHoldTheWord(tester, 'test');
        await iTap(tester, 'Add note');
        await iWriteTheNote(tester, 'A good start');
        await isHighlighted(tester, 'test', 'yellow');
        await hasTheNote(tester, 'test', 'A good start');
        await iOpenTheNotes(tester);
        await iSee(tester, 'A good start');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A note highlights the passage in yellow''',
          success,
        );
      }
    });
    testWidgets('''A tap on a highlight changes its colour, or removes it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A tap on a highlight changes its colour, or removes it''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iHoldTheWord(tester, 'first');
        await iHighlightIt(tester, 'yellow');
        await iTapTheWord(tester, 'first');
        await iSee(tester, 'Remove highlight');
        await iHighlightIt(tester, 'blue');
        await isHighlighted(tester, 'first', 'blue');
        await iTapTheWord(tester, 'first');
        await iTap(tester, 'Remove highlight');
        await hasNoHighlights(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A tap on a highlight changes its colour, or removes it''',
          success,
        );
      }
    });
    testWidgets('''Esc closes the menu, and the selection goes with it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Esc closes the menu, and the selection goes with it''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iHoldTheWord(tester, 'first');
        await iPress(tester, 'Esc');
        await iDoNotSee(tester, 'Add note');
        await theBookIsStillOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Esc closes the menu, and the selection goes with it''',
          success,
        );
      }
    });
    testWidgets('''A highlight removed from the notes is gone from the page''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A highlight removed from the notes is gone from the page''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iHoldTheWord(tester, 'first');
        await iHighlightIt(tester, 'red');
        await iOpenTheNotes(tester);
        await iTapTheButton(tester, 'Remove highlight');
        await iSeeALine(tester, 'No highlights yet');
        await hasNoHighlights(tester, 'book-epub');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A highlight removed from the notes is gone from the page''',
          success,
        );
      }
    });
    testWidgets('''A comic's pages have no text to select, so no notes''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A comic's pages have no text to select, so no notes''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await iOpenTheContents(tester);
        await iDoNotSee(tester, 'Notes');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A comic's pages have no text to select, so no notes''',
          success,
        );
      }
    });
  });
}
