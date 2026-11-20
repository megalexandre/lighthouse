// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_search_for.dart';
import './step/i_open_the_result.dart';
import './step/i_see_the_page_of.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Search''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Typing finds the movie, which opens its page''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Typing finds the movie, which opens its page''');
        await iAmSignedInAsANewUser(tester);
        await iSearchFor(tester, 'test mov');
        await iOpenTheResult(tester, 'Test Movie (2020)');
        await iSeeThePageOf(tester, 'Test Movie (2020)');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Typing finds the movie, which opens its page''',
          success,
        );
      }
    });
  });
}
