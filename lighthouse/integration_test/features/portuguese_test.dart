// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user_with_the_app_as_installed.dart';
import './step/i_see.dart';
import './step/i_play_from.dart';
import './step/i_pause_the_player.dart';
import './step/i_open_the_audio_tracks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Portuguese''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets(
        '''As installed, the app and the track names are in Portuguese''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''As installed, the app and the track names are in Portuguese''');
        await iAmSignedInAsANewUserWithTheAppAsInstalled(tester);
        await iSee(tester, 'Minhas mídias');
        await iSee(tester, 'Novidades em Movies');
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await iPauseThePlayer(tester);
        await iOpenTheAudioTracks(tester);
        await iSee(tester, 'Inglês');
        await iSee(tester, 'Português');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''As installed, the app and the track names are in Portuguese''',
          success,
        );
      }
    });
  });
}
