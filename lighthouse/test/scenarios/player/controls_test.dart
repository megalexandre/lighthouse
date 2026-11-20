// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/the_audio_track_plays.dart';
import './step/no_subtitle_is_shown.dart';
import './step/the_server_is_told_the_audio_track.dart';
import './step/the_server_is_told_no_subtitle.dart';
import './step/the_server_suggests_the_subtitle.dart';
import './step/the_subtitle_is_shown.dart';
import './step/i_pick_the_audio_track_from_the_menu.dart';
import './step/the_menu_has_the_audio_track_checked.dart';
import './step/i_pick_the_subtitle_from_the_menu.dart';
import './step/the_server_is_told_the_subtitle.dart';
import './step/i_turn_the_subtitles_off_from_the_menu.dart';
import './step/i_press.dart';
import './step/the_volume_is.dart';
import './step/i_tap_the_button.dart';
import './step/the_volume_is_muted.dart';
import './step/i_see_a_button.dart';
import './step/the_server_is_told_the_volume_is_muted.dart';
import './step/the_player_is_full_screen.dart';
import './step/the_window_is_not_full_screen.dart';
import './step/the_movie_plays_as_a_transcode.dart';
import './step/seconds_have_played.dart';
import './step/the_server_is_asked_for_a_new_stream_from_seconds_with_the_audio_track.dart';
import './step/it_started_at_seconds.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/the_server_is_asked_for_a_new_stream_from_seconds_with_the_subtitle.dart';
import './step/mpv_cannot_open_the_stream.dart';
import './step/i_see.dart';
import './step/the_server_stops_answering.dart';
import './step/i_see_the_message.dart';
import './step/only_one_stream_was_opened.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Player controls''', () {
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

    testWidgets('''It starts with the server's default audio and no subtitle''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''It starts with the server's default audio and no subtitle''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await theAudioTrackPlays(tester, 'English');
        await noSubtitleIsShown(tester);
        await theServerIsToldTheAudioTrack(tester, 'English');
        await theServerIsToldNoSubtitle(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''It starts with the server's default audio and no subtitle''',
          success,
        );
      }
    });
    testWidgets('''A subtitle the server suggests shows from the start''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A subtitle the server suggests shows from the start''');
        await bddSetUp(tester);
        await theServerSuggestsTheSubtitle(tester, 'English');
        await iPlay(tester, 'movie-1');
        await theSubtitleIsShown(tester, 'English');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A subtitle the server suggests shows from the start''',
          success,
        );
      }
    });
    testWidgets('''An audio track picked from the menu''', (tester) async {
      var success = true;
      try {
        await beforeEach('''An audio track picked from the menu''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPickTheAudioTrackFromTheMenu(tester, 'Portuguese');
        await theAudioTrackPlays(tester, 'Portuguese');
        await theServerIsToldTheAudioTrack(tester, 'Portuguese');
        await theMenuHasTheAudioTrackChecked(tester, 'Portuguese');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''An audio track picked from the menu''',
          success,
        );
      }
    });
    testWidgets('''A subtitle picked from the menu, then turned off''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A subtitle picked from the menu, then turned off''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPickTheSubtitleFromTheMenu(tester, 'Portuguese');
        await theSubtitleIsShown(tester, 'Portuguese');
        await theServerIsToldTheSubtitle(tester, 'Portuguese');
        await iTurnTheSubtitlesOffFromTheMenu(tester);
        await noSubtitleIsShown(tester);
        await theServerIsToldNoSubtitle(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A subtitle picked from the menu, then turned off''',
          success,
        );
      }
    });
    testWidgets('''A cycles the audio''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A cycles the audio''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'A');
        await theAudioTrackPlays(tester, 'Portuguese');
        await iPress(tester, 'A');
        await theAudioTrackPlays(tester, 'English');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A cycles the audio''',
          success,
        );
      }
    });
    testWidgets('''Ctrl+A cycles the audio the other way''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Ctrl+A cycles the audio the other way''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'Ctrl+A');
        await theAudioTrackPlays(tester, 'Portuguese');
        await iPress(tester, 'Ctrl+A');
        await theAudioTrackPlays(tester, 'English');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Ctrl+A cycles the audio the other way''',
          success,
        );
      }
    });
    testWidgets(
        '''L cycles the subtitles through off; S shows and hides them''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''L cycles the subtitles through off; S shows and hides them''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'L');
        await theSubtitleIsShown(tester, 'Portuguese');
        await iPress(tester, 'L');
        await theSubtitleIsShown(tester, 'English');
        await iPress(tester, 'L');
        await noSubtitleIsShown(tester);
        await iPress(tester, 'S');
        await theSubtitleIsShown(tester, 'English');
        await iPress(tester, 'S');
        await noSubtitleIsShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''L cycles the subtitles through off; S shows and hides them''',
          success,
        );
      }
    });
    testWidgets('''Ctrl+L cycles the subtitles the other way''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Ctrl+L cycles the subtitles the other way''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'Ctrl+L');
        await theSubtitleIsShown(tester, 'English');
        await iPress(tester, 'Ctrl+L');
        await theSubtitleIsShown(tester, 'Portuguese');
        await iPress(tester, 'Ctrl+L');
        await noSubtitleIsShown(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Ctrl+L cycles the subtitles the other way''',
          success,
        );
      }
    });
    testWidgets(
        '''The volume, from the arrows and mute, and what the server is told''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The volume, from the arrows and mute, and what the server is told''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'Down');
        await iPress(tester, 'Down');
        await theVolumeIs(tester, 90);
        await iPress(tester, 'Up');
        await theVolumeIs(tester, 95);
        await iTapTheButton(tester, 'mute');
        await theVolumeIsMuted(tester, 95);
        await iSeeAButton(tester, 'Unmute (M)');
        await iPress(tester, 'Up');
        await theVolumeIs(tester, 100);
        await iPress(tester, 'M');
        await iTapTheButton(tester, 'play/pause');
        await theServerIsToldTheVolumeIsMuted(tester, 100);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The volume, from the arrows and mute, and what the server is told''',
          success,
        );
      }
    });
    testWidgets(
        '''Full screen from F11, the button and F; leaving gives the window back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Full screen from F11, the button and F; leaving gives the window back''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'F11');
        await thePlayerIsFullScreen(tester);
        await iSeeAButton(tester, 'Exit full screen (F)');
        await iTapTheButton(tester, 'full screen');
        await theWindowIsNotFullScreen(tester);
        await iPress(tester, 'F');
        await thePlayerIsFullScreen(tester);
        await iPress(tester, 'Esc');
        await theWindowIsNotFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Full screen from F11, the button and F; leaving gives the window back''',
          success,
        );
      }
    });
    testWidgets(
        '''In a transcode, another audio track is a new stream from the same place''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In a transcode, another audio track is a new stream from the same place''');
        await bddSetUp(tester);
        await theMoviePlaysAsATranscode(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iPickTheAudioTrackFromTheMenu(tester, 'Portuguese');
        await theServerIsAskedForANewStreamFromSecondsWithTheAudioTrack(
            tester, 30, 'Portuguese');
        await itStartedAtSeconds(tester, 30);
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In a transcode, another audio track is a new stream from the same place''',
          success,
        );
      }
    });
    testWidgets(
        '''In a transcode, a subtitle inside the file is a new stream from the same place''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In a transcode, a subtitle inside the file is a new stream from the same place''');
        await bddSetUp(tester);
        await theMoviePlaysAsATranscode(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iPickTheSubtitleFromTheMenu(tester, 'English');
        await theServerIsAskedForANewStreamFromSecondsWithTheSubtitle(
            tester, 30, 'English');
        await itStartedAtSeconds(tester, 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In a transcode, a subtitle inside the file is a new stream from the same place''',
          success,
        );
      }
    });
    testWidgets('''A stream mpv cannot open says so''', (tester) async {
      var success = true;
      try {
        await beforeEach('''A stream mpv cannot open says so''');
        await bddSetUp(tester);
        await mpvCannotOpenTheStream(tester);
        await iPlay(tester, 'movie-1');
        await iSee(tester, 'Playback failed: the stream could not be opened.');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A stream mpv cannot open says so''',
          success,
        );
      }
    });
    testWidgets(
        '''In a transcode, a stream the server cannot give leaves the old one playing''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''In a transcode, a stream the server cannot give leaves the old one playing''');
        await bddSetUp(tester);
        await theMoviePlaysAsATranscode(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await theServerStopsAnswering(tester);
        await iPickTheAudioTrackFromTheMenu(tester, 'Portuguese');
        await iSeeTheMessage(tester, 'The server answered with error 503.');
        await onlyOneStreamWasOpened(tester);
        await secondsHavePlayed(tester, 10);
        await iPress(tester, 'Esc');
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 40);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''In a transcode, a stream the server cannot give leaves the old one playing''',
          success,
        );
      }
    });
  });
}
