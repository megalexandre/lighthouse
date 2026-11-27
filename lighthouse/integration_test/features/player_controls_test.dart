// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_play_from.dart';
import './step/i_press_in_the_player.dart';
import './step/i_pick_the_speed.dart';
import './step/mpv_plays_at_volume_muted_at_times_the_speed.dart';
import './step/mpv_draws_at_the_size_the_video_takes_on_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Player controls''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }

    Future<void> afterEach(String title, bool success,
        [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }

    testWidgets('''Volume, mute and speed reach mpv''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Volume, mute and speed reach mpv''');
        await iAmSignedInAsANewUser(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await iPressInThePlayer(tester, 'Down');
        await iPressInThePlayer(tester, 'Down');
        await iPressInThePlayer(tester, 'M');
        await iPickTheSpeed(tester, 1.5);
        await mpvPlaysAtVolumeMutedAtTimesTheSpeed(tester, 90, 1.5);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Volume, mute and speed reach mpv''',
          success,
        );
      }
    });
    testWidgets('''mpv draws the picture at its size on screen''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''mpv draws the picture at its size on screen''');
        await iAmSignedInAsANewUser(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await mpvDrawsAtTheSizeTheVideoTakesOnScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''mpv draws the picture at its size on screen''',
          success,
        );
      }
    });
  });
}
