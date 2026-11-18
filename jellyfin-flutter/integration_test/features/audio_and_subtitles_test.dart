// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_choose_as_the_audio_language_in_settings.dart';
import './step/the_server_keeps_as_the_audio_language.dart';
import './step/i_play_from.dart';
import './step/mpv_plays_the_audio_track.dart';
import './step/mpv_checks_https_certificates.dart';
import './step/i_pause_the_player.dart';
import './step/i_switch_the_audio_to_portuguese.dart';
import './step/i_turn_on_the_external_portuguese_subtitle.dart';
import './step/mpv_shows_the_external_subtitle_line.dart';
import './step/i_turn_the_subtitles_off.dart';
import './step/mpv_shows_no_subtitle.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Audio and subtitles''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmSignedInAsANewUser(tester);
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
      '''Portuguese audio chosen in Settings is what the movie plays''',
      (tester) async {
        var success = true;
        try {
          await beforeEach(
            '''Portuguese audio chosen in Settings is what the movie plays''',
          );
          await bddSetUp(tester);
          await iChooseAsTheAudioLanguageInSettings(tester, 'Portuguese');
          await theServerKeepsAsTheAudioLanguage(tester, 'por');
          await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
          await mpvPlaysTheAudioTrack(tester, 'por');
        } catch (_) {
          success = false;
          rethrow;
        } finally {
          await afterEach(
            '''Portuguese audio chosen in Settings is what the movie plays''',
            success,
          );
        }
      },
    );
    testWidgets('''Switching the audio and the subtitle in the player''', (
      tester,
    ) async {
      var success = true;
      try {
        await beforeEach(
          '''Switching the audio and the subtitle in the player''',
        );
        await bddSetUp(tester);
        await iPlayFrom(tester, 'Test Movie (2020)', 'Movies');
        await mpvPlaysTheAudioTrack(tester, 'eng');
        await mpvChecksHttpsCertificates(tester);
        await iPauseThePlayer(tester);
        await iSwitchTheAudioToPortuguese(tester);
        await mpvPlaysTheAudioTrack(tester, 'por');
        await iTurnOnTheExternalPortugueseSubtitle(tester);
        await mpvShowsTheExternalSubtitleLine(tester, 'Português subtitle one');
        await iTurnTheSubtitlesOff(tester);
        await mpvShowsNoSubtitle(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Switching the audio and the subtitle in the player''',
          success,
        );
      }
    });
  });
}
