// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_play_from.dart';
import './step/i_pause_after_seconds_and_leave_the_player.dart';
import './step/the_server_keeps_the_place_where_i_paused.dart';
import './step/resume_starts_the_movie_there.dart';
import './step/i_skip_to_the_end.dart';
import './step/i_am_back_on_the_items_page.dart';
import './step/the_server_has_as_watched.dart';
import './step/i_go_back.dart';
import './step/shows_as_watched.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Watching''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmSignedInAsANewUser(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''Leaving a movie halfway keeps the place, and Resume starts there''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Leaving a movie halfway keeps the place, and Resume starts there''');
        await bddSetUp(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await iPauseAfterSecondsAndLeaveThePlayer(tester, 2);
        await theServerKeepsThePlaceWhereIPaused(tester);
        await resumeStartsTheMovieThere(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Leaving a movie halfway keeps the place, and Resume starts there''',
          success,
        );
      }
    });
    testWidgets('''A movie played to its end is watched''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A movie played to its end is watched''');
        await bddSetUp(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await iSkipToTheEnd(tester);
        await iAmBackOnTheItemsPage(tester);
        await theServerHasAsWatched(tester, 'Test Movie (2020)');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie played to its end is watched''',
          success,
        );
      }
    });
    testWidgets('''A movie played to its end shows as watched in its library''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A movie played to its end shows as watched in its library''');
        await bddSetUp(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await iSkipToTheEnd(tester);
        await iAmBackOnTheItemsPage(tester);
        await iGoBack(tester);
        await showsAsWatched(tester, 'Test Movie (2020)');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A movie played to its end shows as watched in its library''',
          success,
        );
      }
    });
  });
}
