// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_started_for_the_first_time.dart';
import './step/i_see_the_connect_screen_with_an_empty_address.dart';
import './step/i_connect_to.dart';
import './step/i_see_the_login_screen_of.dart';
import './step/i_type_the_address_and_press_enter.dart';
import './step/nothing_answers_at.dart';
import './step/i_see_the_error.dart';
import './step/i_am_still_on_the_connect_screen.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Connect''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsStartedForTheFirstTime(tester);
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

    testWidgets('''A first start asks for the server's address''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A first start asks for the server's address''');
        await bddSetUp(tester);
        await iSeeTheConnectScreenWithAnEmptyAddress(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A first start asks for the server's address''',
          success,
        );
      }
    });
    testWidgets('''A working server leads to its login screen''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A working server leads to its login screen''');
        await bddSetUp(tester);
        await iConnectTo(tester, 'http://jellyfin.test:8096');
        await iSeeTheLoginScreenOf(tester, 'Test Server');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A working server leads to its login screen''',
          success,
        );
      }
    });
    testWidgets('''Pressing Enter connects too''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Pressing Enter connects too''');
        await bddSetUp(tester);
        await iTypeTheAddressAndPressEnter(tester, 'http://jellyfin.test:8096');
        await iSeeTheLoginScreenOf(tester, 'Test Server');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''Pressing Enter connects too''', success);
      }
    });
    testWidgets('''A server that does not answer says why''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A server that does not answer says why''');
        await bddSetUp(tester);
        await nothingAnswersAt(tester, 'http://nowhere:8096');
        await iConnectTo(tester, 'http://nowhere:8096');
        await iSeeTheError(
          tester,
          'Cannot reach http://nowhere:8096. Check the address and that the server is running.',
        );
        await iAmStillOnTheConnectScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''A server that does not answer says why''', success);
      }
    });
    testWidgets('''An empty address is not sent''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An empty address is not sent''');
        await bddSetUp(tester);
        await iConnectTo(tester, '  ');
        await iSeeTheError(tester, 'Enter the server address.');
        await iAmStillOnTheConnectScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''An empty address is not sent''', success);
      }
    });
  });
}
