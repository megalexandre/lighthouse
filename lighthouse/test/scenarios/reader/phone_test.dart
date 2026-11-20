// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_read.dart';
import './step/i_open_the_contents.dart';
import './step/i_use_the_phones_back.dart';
import './step/the_contents_are_closed.dart';
import './step/the_book_is_still_open.dart';
import './step/i_am_back_on_the_books_page.dart';

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
  });
}
