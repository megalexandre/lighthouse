// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/i_switch_the_audio_with_the_keyboard.dart';
import './step/the_audio_track_plays.dart';
import './step/the_movie_plays_as_a_transcode.dart';
import './step/the_server_stops_answering.dart';
import './step/i_see_the_message.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Tracks from the keyboard''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsSignedIn(tester);
    }

    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''A switches to the next audio track''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A switches to the next audio track''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iSwitchTheAudioWithTheKeyboard(tester);
        await theAudioTrackPlays(tester, 'Portuguese');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A switches to the next audio track''',
          success,
        );
      }
    });
    testWidgets('''An audio track the server cannot give says so''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''An audio track the server cannot give says so''');
        await bddSetUp(tester);
        await theMoviePlaysAsATranscode(tester);
        await iPlay(tester, 'movie-1');
        await theServerStopsAnswering(tester);
        await iSwitchTheAudioWithTheKeyboard(tester);
        await iSeeTheMessage(tester, 'The server answered with error 503.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An audio track the server cannot give says so''',
          success,
        );
      }
    });
  });
}
