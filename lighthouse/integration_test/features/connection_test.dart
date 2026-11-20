// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user_through_a_proxy.dart';
import './step/the_server_goes_away.dart';
import './step/i_tap_the_library.dart';
import './step/i_see_the_connection_banner.dart';
import './step/the_library_does_not_show.dart';
import './step/the_server_is_back.dart';
import './step/the_library_shows.dart';
import './step/the_connection_banner_is_gone.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Connection''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''The banner while the server is away; back, the grid loads by itself''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The banner while the server is away; back, the grid loads by itself''');
        await iAmSignedInAsANewUserThroughAProxy(tester);
        await theServerGoesAway(tester);
        await iTapTheLibrary(tester, 'Movies');
        await iSeeTheConnectionBanner(tester);
        await theLibraryDoesNotShow(tester, 'Test Movie (2020)');
        await theServerIsBack(tester);
        await theLibraryShows(tester, 'Test Movie (2020)');
        await theConnectionBannerIsGone(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The banner while the server is away; back, the grid loads by itself''',
          success,
        );
      }
    });
  });
}
