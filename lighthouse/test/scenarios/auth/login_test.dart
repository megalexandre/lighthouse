// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_connected_to_a_server.dart';
import './step/i_see_the_login_screen_of.dart';
import './step/i_sign_in_as_with_password.dart';
import './step/i_see_the_home_screen_signed_in_as.dart';
import './step/i_see_the_error.dart';
import './step/i_am_still_on_the_login_screen.dart';
import './step/i_type_the_password.dart';
import './step/the_password_is_hidden.dart';
import './step/i_restart_the_app.dart';
import './step/i_sign_out.dart';
import './step/the_server_is_told_i_signed_out.dart';
import './step/i_change_server.dart';
import './step/i_see_the_connect_screen_with_an_empty_address.dart';

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

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''A stored server opens on its login screen''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A stored server opens on its login screen''');
        await bddSetUp(tester);
        await iSeeTheLoginScreenOf(
            tester, 'Test Server · http://jellyfin.test:8096');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A stored server opens on its login screen''',
          success,
        );
      }
    });
    testWidgets('''The right username and password open the home screen''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The right username and password open the home screen''');
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
        await afterEach(
          '''A wrong password shows an error''',
          success,
        );
      }
    });
    testWidgets('''The password is hidden''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The password is hidden''');
        await bddSetUp(tester);
        await iTypeThePassword(tester, 'secret');
        await thePasswordIsHidden(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The password is hidden''',
          success,
        );
      }
    });
    testWidgets('''Once signed in, a restart opens home''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Once signed in, a restart opens home''');
        await bddSetUp(tester);
        await iSignInAsWithPassword(tester, 'alice', 'secret');
        await iRestartTheApp(tester);
        await iSeeTheHomeScreenSignedInAs(tester, 'alice');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Once signed in, a restart opens home''',
          success,
        );
      }
    });
    testWidgets('''Signing out comes back to the same server''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Signing out comes back to the same server''');
        await bddSetUp(tester);
        await iSignInAsWithPassword(tester, 'alice', 'secret');
        await iSignOut(tester);
        await iSeeTheLoginScreenOf(tester, 'Test Server');
        await theServerIsToldISignedOut(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Signing out comes back to the same server''',
          success,
        );
      }
    });
    testWidgets('''Changing server forgets this one''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Changing server forgets this one''');
        await bddSetUp(tester);
        await iChangeServer(tester);
        await iSeeTheConnectScreenWithAnEmptyAddress(tester);
        await iRestartTheApp(tester);
        await iSeeTheConnectScreenWithAnEmptyAddress(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Changing server forgets this one''',
          success,
        );
      }
    });
  });
}
