// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_play_episode_of.dart';
import './step/i_skip_to_the_end.dart';
import './step/is_playing.dart';
import './step/the_server_has_as_watched.dart';
import './step/i_leave_the_player.dart';
import './step/i_go_back.dart';
import './step/shows_as_watched.dart';
import './step/i_play_from.dart';
import './step/i_tap_next.dart';
import './step/there_is_no_next_track.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Play on''', () {
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

    testWidgets('''An episode played to its end starts the next one''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''An episode played to its end starts the next one''');
        await bddSetUp(tester);
        await iPlayEpisodeOf(tester, 'Test Show S01E01', 'Test Show');
        await iSkipToTheEnd(tester);
        await isPlaying(tester, 'Test Show S01E02');
        await theServerHasAsWatched(tester, 'Test Show S01E01');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An episode played to its end starts the next one''',
          success,
        );
      }
    });
    testWidgets(
        '''An episode played to its end shows as watched in its season''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''An episode played to its end shows as watched in its season''');
        await bddSetUp(tester);
        await iPlayEpisodeOf(tester, 'Test Show S01E01', 'Test Show');
        await iSkipToTheEnd(tester);
        await isPlaying(tester, 'Test Show S01E02');
        await iLeaveThePlayer(tester);
        await iGoBack(tester);
        await showsAsWatched(tester, 'Test Show S01E01');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An episode played to its end shows as watched in its season''',
          success,
        );
      }
    });
    testWidgets('''Next plays the album's second track''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Next plays the album's second track''');
        await bddSetUp(tester);
        await iPlayFrom(tester, 'Test Album', 'Music');
        await isPlaying(tester, 'Track 1');
        await iTapNext(tester);
        await isPlaying(tester, 'Track 2');
        await thereIsNoNextTrack(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Next plays the album's second track''',
          success,
        );
      }
    });
  });
}
