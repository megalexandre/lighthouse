// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_as_installed.dart';
import './step/i_open_settings.dart';
import './step/i_see_the_setting.dart';
import './step/i_choose_the_language.dart';
import './step/i_restart_the_app.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Language''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''A new install speaks Brazilian Portuguese''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''A new install speaks Brazilian Portuguese''');
        await theAppAsInstalled(tester);
        await iOpenSettings(tester);
        await iSeeTheSetting(tester, 'Idioma');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A new install speaks Brazilian Portuguese''',
          success,
        );
      }
    });
    testWidgets('''Choosing English changes the texts, and is kept''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Choosing English changes the texts, and is kept''');
        await theAppAsInstalled(tester);
        await iOpenSettings(tester);
        await iChooseTheLanguage(tester, 'English');
        await iSeeTheSetting(tester, 'Language');
        await iRestartTheApp(tester);
        await iOpenSettings(tester);
        await iSeeTheSetting(tester, 'Language');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Choosing English changes the texts, and is kept''',
          success,
        );
      }
    });
  });
}
