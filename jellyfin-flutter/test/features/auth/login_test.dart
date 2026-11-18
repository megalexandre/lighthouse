// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_connected_to_a_server.dart';
import './step/i_sign_in_as_with_password.dart';
import './step/i_see_the_home_screen_signed_in_as.dart';
import './step/i_see_the_error.dart';
import './step/i_am_still_on_the_login_screen.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Login''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsConnectedToAServer(tester);
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

    testWidgets('''The right username and password open the home screen''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach(
          '''The right username and password open the home screen''',
        );
        await bddSetUp(tester);
        await iSignInAsWithPassword(tester, 'alice', 'secret');
        await iSeeTheHomeScreenSignedInAs(tester, 'alice');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The right username and password open the home screen''',
          success,
        );
      }
    });
    testWidgets('''A wrong password shows an error''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A wrong password shows an error''');
        await bddSetUp(tester);
        await iSignInAsWithPassword(tester, 'alice', 'wrong');
        await iSeeTheError(tester, 'Wrong username or password.');
        await iAmStillOnTheLoginScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''A wrong password shows an error''', success);
      }
    });
  });
}
