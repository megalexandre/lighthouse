// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/a_new_user_with_password.dart';
import './step/the_app_is_connected_to_the_test_server.dart';
import './step/i_sign_in_with_password.dart';
import './step/i_see_the_home_screen_signed_in_as_the_new_user.dart';
import './step/i_restart_the_app.dart';
import './step/i_see_the_error.dart';
import './step/i_am_on_the_login_screen.dart';
import './step/i_sign_out.dart';
import './step/the_server_no_longer_accepts_the_old_session.dart';
import './step/the_session_is_ended_on_the_server_while_the_app_is_closed.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Login''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aNewUserWithPassword(tester, 'pw-123');
      await theAppIsConnectedToTheTestServer(tester);
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

    testWidgets(
      '''The right password opens home, and a restart stays signed in''',
      (tester) async {
        var success = true;
        try {
          await beforeEach(
            '''The right password opens home, and a restart stays signed in''',
          );
          await bddSetUp(tester);
          await iSignInWithPassword(tester, 'pw-123');
          await iSeeTheHomeScreenSignedInAsTheNewUser(tester);
          await iRestartTheApp(tester);
          await iSeeTheHomeScreenSignedInAsTheNewUser(tester);
        } catch (_) {
          success = false;
          rethrow;
        } finally {
          await afterEach(
            '''The right password opens home, and a restart stays signed in''',
            success,
          );
        }
      },
    );
    testWidgets('''A wrong password shows an error''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A wrong password shows an error''');
        await bddSetUp(tester);
        await iSignInWithPassword(tester, 'wrong');
        await iSeeTheError(tester, 'Wrong username or password.');
        await iAmOnTheLoginScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach('''A wrong password shows an error''', success);
      }
    });
    testWidgets('''Signing out ends the session on the server''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''Signing out ends the session on the server''');
        await bddSetUp(tester);
        await iSignInWithPassword(tester, 'pw-123');
        await iSignOut(tester);
        await iAmOnTheLoginScreen(tester);
        await theServerNoLongerAcceptsTheOldSession(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Signing out ends the session on the server''',
          success,
        );
      }
    });
    testWidgets('''A session ended elsewhere asks to sign in again''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach('''A session ended elsewhere asks to sign in again''');
        await bddSetUp(tester);
        await iSignInWithPassword(tester, 'pw-123');
        await theSessionIsEndedOnTheServerWhileTheAppIsClosed(tester);
        await iRestartTheApp(tester);
        await iAmOnTheLoginScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A session ended elsewhere asks to sign in again''',
          success,
        );
      }
    });
  });
}
