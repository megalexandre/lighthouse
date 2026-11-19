// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_read.dart';
import './step/the_server_goes_away.dart';
import './step/i_turn_the_page_with_the_right_arrow_key.dart';
import './step/i_close_the_book.dart';
import './step/i_read_it_again.dart';
import './step/the_reader_shows.dart';
import './step/the_server_is_back.dart';
import './step/the_server_keeps_page_of.dart';
import './step/i_go_to_the_last_page.dart';
import './step/the_server_has_as_read.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Reading while the server is away''', () {
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
        '''A page turned while the server is away is kept, and sent when it is back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A page turned while the server is away is kept, and sent when it is back''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await theServerGoesAway(tester);
        await iTurnThePageWithTheRightArrowKey(tester);
        await iTurnThePageWithTheRightArrowKey(tester);
        await iCloseTheBook(tester);
        await iReadItAgain(tester);
        await theReaderShows(tester, 'Page 3 of 5');
        await theServerIsBack(tester);
        await theServerKeepsPageOf(tester, 3, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A page turned while the server is away is kept, and sent when it is back''',
          success,
        );
      }
    });
    testWidgets(
        '''A book finished while the server is away is marked read when it is back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A book finished while the server is away is marked read when it is back''');
        await bddSetUp(tester);
        await iRead(tester, 'book-comic');
        await theServerGoesAway(tester);
        await iGoToTheLastPage(tester);
        await iCloseTheBook(tester);
        await theServerIsBack(tester);
        await theServerHasAsRead(tester, 'book-comic');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A book finished while the server is away is marked read when it is back''',
          success,
        );
      }
    });
  });
}
