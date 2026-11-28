// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_reader_shows_one_page_at_a_time.dart';
import './step/i_read.dart';
import './step/i_turn_the_page_with_the_right_arrow_key.dart';
import './step/i_drag_the_page_px_to_the_left.dart';
import './step/the_reader_shows.dart';
import './step/the_page_swished_times.dart';
import './step/nothing_rubbed.dart';
import './step/i_open_the_display_settings.dart';
import './step/i_do_not_see.dart';
import './step/the_page_sound_is_available.dart';
import './step/the_paper_rubbed.dart';
import './step/the_paper_is_quiet.dart';
import './step/i_tap_the_edge.dart';
import './step/i_scroll_the_mouse_wheel.dart';
import './step/i_press.dart';
import './step/i_turn_the_page_sound_off.dart';
import './step/i_close_the_display_settings.dart';
import './step/the_page_sound_is_kept_off.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Page sound''', () {
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

    testWidgets('''For now there is no page sound, and nothing to turn it on''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''For now there is no page sound, and nothing to turn it on''');
        await bddSetUp(tester);
        await iRead(tester, 'book-epub');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iDragThePagePxToTheLeft(tester, 'quickly', 600);
        await theReaderShows(tester, 'Page 3 of 3');
        await thePageSwishedTimes(tester, 0);
        await nothingRubbed(tester);
        await iOpenTheDisplaySettings(tester);
        await iDoNotSee(tester, 'Paper sound as pages turn');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''For now there is no page sound, and nothing to turn it on''',
          success,
        );
      }
    });
    testWidgets(
        '''A page dragged slowly rubs softly, and falls back without a swish''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A page dragged slowly rubs softly, and falls back without a swish''');
        await bddSetUp(tester);
        await thePageSoundIsAvailable(tester);
        await iRead(tester, 'book-comic');
        await iDragThePagePxToTheLeft(tester, 'slowly', 60);
        await thePaperRubbed(tester, 'softly');
        await thePaperIsQuiet(tester);
        await thePageSwishedTimes(tester, 0);
        await theReaderShows(tester, 'Page 1 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A page dragged slowly rubs softly, and falls back without a swish''',
          success,
        );
      }
    });
    testWidgets(
        '''A page dragged quickly rubs loudly, and swishes as it turns''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A page dragged quickly rubs loudly, and swishes as it turns''');
        await bddSetUp(tester);
        await thePageSoundIsAvailable(tester);
        await iRead(tester, 'book-comic');
        await iDragThePagePxToTheLeft(tester, 'quickly', 600);
        await thePaperRubbed(tester, 'loudly');
        await thePaperIsQuiet(tester);
        await thePageSwishedTimes(tester, 1);
        await theReaderShows(tester, 'Page 2 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A page dragged quickly rubs loudly, and swishes as it turns''',
          success,
        );
      }
    });
    testWidgets(
        '''Keys, the edges and the wheel swish once per page, without rubbing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Keys, the edges and the wheel swish once per page, without rubbing''');
        await bddSetUp(tester);
        await thePageSoundIsAvailable(tester);
        await iRead(tester, 'book-comic');
        await iTurnThePageWithTheRightArrowKey(tester);
        await iTapTheEdge(tester, 'right');
        await iScrollTheMouseWheel(tester, 'down');
        await theReaderShows(tester, 'Page 4 of 5');
        await thePageSwishedTimes(tester, 3);
        await nothingRubbed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Keys, the edges and the wheel swish once per page, without rubbing''',
          success,
        );
      }
    });
    testWidgets(
        '''The last page does not swish when there is nothing to turn to''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The last page does not swish when there is nothing to turn to''');
        await bddSetUp(tester);
        await thePageSoundIsAvailable(tester);
        await iRead(tester, 'book-comic');
        await iPress(tester, 'End');
        await iPress(tester, 'Right');
        await thePageSwishedTimes(tester, 0);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The last page does not swish when there is nothing to turn to''',
          success,
        );
      }
    });
    testWidgets('''Turned off, pages turn in silence, and it stays off''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Turned off, pages turn in silence, and it stays off''');
        await bddSetUp(tester);
        await thePageSoundIsAvailable(tester);
        await iRead(tester, 'book-epub');
        await iOpenTheDisplaySettings(tester);
        await iTurnThePageSoundOff(tester);
        await iCloseTheDisplaySettings(tester);
        await iTurnThePageWithTheRightArrowKey(tester);
        await iDragThePagePxToTheLeft(tester, 'quickly', 600);
        await theReaderShows(tester, 'Page 3 of 3');
        await thePageSwishedTimes(tester, 0);
        await nothingRubbed(tester);
        await thePageSoundIsKeptOff(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Turned off, pages turn in silence, and it stays off''',
          success,
        );
      }
    });
  });
}
