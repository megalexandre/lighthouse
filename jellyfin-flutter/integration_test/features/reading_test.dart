// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_read_from.dart';
import './step/the_reader_shows.dart';
import './step/i_turn_the_page_with_a_swipe.dart';
import './step/i_turn_the_page_with_the_right_arrow_key.dart';
import './step/i_close_the_book.dart';
import './step/i_see.dart';
import './step/the_server_keeps_page_of.dart';
import './step/i_read_it_again.dart';
import './step/the_server_keeps_the_fraction_of_i_read.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Reading''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmSignedInAsANewUser(tester);
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

    testWidgets('''A comic keeps its page, and opens there again''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A comic keeps its page, and opens there again''');
        await bddSetUp(tester);
        await iReadFrom(tester, 'Test Comic', 'Books');
        await theReaderShows(tester, 'Page 1 of 5');
        await iTurnThePageWithASwipe(tester);
        await iTurnThePageWithTheRightArrowKey(tester);
        await theReaderShows(tester, 'Page 3 of 5');
        await iCloseTheBook(tester);
        await iSee(tester, 'Continue reading · 40%');
        await theServerKeepsPageOf(tester, 3, 'Test Comic');
        await iReadItAgain(tester);
        await theReaderShows(tester, 'Page 3 of 5');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A comic keeps its page, and opens there again''',
          success,
        );
      }
    });
    testWidgets('''An EPUB keeps the fraction read''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An EPUB keeps the fraction read''');
        await bddSetUp(tester);
        await iReadFrom(tester, 'Test Novel', 'Books');
        await theReaderShows(tester, 'Page 1 of 3');
        await iTurnThePageWithTheRightArrowKey(tester);
        await theReaderShows(tester, 'Page 2 of 3');
        await iCloseTheBook(tester);
        await theServerKeepsTheFractionOfIRead(tester, 'Test Novel');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''An EPUB keeps the fraction read''', success);
      }
    });
  });
}
