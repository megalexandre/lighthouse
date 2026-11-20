// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_am_on_the_home_screen.dart';
import './step/i_do_not_see_the_connection_banner.dart';
import './step/the_server_goes_away.dart';
import './step/i_see_the_connection_banner.dart';
import './step/i_do_not_see_the_libraries.dart';
import './step/i_wait.dart';
import './step/the_server_is_back.dart';
import './step/i_see_the_libraries.dart';
import './step/i_tap_retry_now.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Connection''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
      await iAmOnTheHomeScreen(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''A banner while the server is away; back, home loads by itself''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A banner while the server is away; back, home loads by itself''');
        await bddSetUp(tester);
        await iDoNotSeeTheConnectionBanner(tester);
        await theServerGoesAway(tester);
        await iSeeTheConnectionBanner(tester);
        await iDoNotSeeTheLibraries(tester);
        await iWait(tester, '1 second');
        await iSeeTheConnectionBanner(tester);
        await theServerIsBack(tester);
        await iWait(tester, '2 seconds');
        await iDoNotSeeTheConnectionBanner(tester);
        await iSeeTheLibraries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A banner while the server is away; back, home loads by itself''',
          success,
        );
      }
    });
    testWidgets('''Retry now does not wait for the next try''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Retry now does not wait for the next try''');
        await bddSetUp(tester);
        await theServerGoesAway(tester);
        await theServerIsBack(tester);
        await iTapRetryNow(tester);
        await iDoNotSeeTheConnectionBanner(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Retry now does not wait for the next try''',
          success,
        );
      }
    });
  });
}
