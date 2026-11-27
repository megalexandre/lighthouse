// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/i_tap_the_button.dart';
import './step/the_player_floats.dart';
import './step/i_hover_over_the_floating_window.dart';
import './step/the_player_is_back_in_its_window.dart';
import './step/the_video_is_by_pixels.dart';
import './step/i_press.dart';
import './step/the_floating_window_is_times_as_wide_as_high.dart';
import './step/the_player_is_still_open.dart';
import './step/the_window_is_not_full_screen.dart';
import './step/the_player_is_full_screen.dart';
import './step/i_click_the_floating_window.dart';
import './step/it_is_paused.dart';
import './step/i_drag_the_floating_window.dart';
import './step/the_floating_window_has_moved.dart';
import './step/seconds_have_played.dart';
import './step/the_player_is_closed.dart';
import './step/the_window_does_not_float.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/it_plays_to_its_end.dart';
import './step/is_playing.dart';
import './step/there_is_no_button.dart';
import './step/the_app_runs_on_a.dart';
import './step/i_go_to_the_phones_home.dart';
import './step/the_floating_windows_middle_button_is.dart';
import './step/i_use_the_floating_windows.dart';
import './step/it_is_at_seconds.dart';
import './step/the_floating_window_grows_back.dart';
import './step/the_floating_window_is_closed.dart';
import './step/the_phone_cannot_float.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''The floating window''', () {
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

    testWidgets('''The button floats the video and gives the window back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''The button floats the video and gives the window back''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'floating window');
        await thePlayerFloats(tester);
        await iHoverOverTheFloatingWindow(tester);
        await iTapTheButton(tester, 'back to the window');
        await thePlayerIsBackInItsWindow(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The button floats the video and gives the window back''',
          success,
        );
      }
    });
    testWidgets('''The window takes the picture's shape''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The window takes the picture's shape''');
        await bddSetUp(tester);
        await theVideoIsByPixels(tester, 1920, 800);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'I');
        await theFloatingWindowIsTimesAsWideAsHigh(tester, 2.4);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The window takes the picture's shape''',
          success,
        );
      }
    });
    testWidgets('''Esc gives the window back and does not leave the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Esc gives the window back and does not leave the player''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'I');
        await iPress(tester, 'Esc');
        await thePlayerIsBackInItsWindow(tester);
        await thePlayerIsStillOpen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Esc gives the window back and does not leave the player''',
          success,
        );
      }
    });
    testWidgets('''Full screen ends to float and comes back after''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Full screen ends to float and comes back after''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'F');
        await iPress(tester, 'I');
        await thePlayerFloats(tester);
        await theWindowIsNotFullScreen(tester);
        await iPress(tester, 'I');
        await thePlayerIsFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Full screen ends to float and comes back after''',
          success,
        );
      }
    });
    testWidgets('''A click on the floating window pauses, dragging moves it''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A click on the floating window pauses, dragging moves it''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await iPress(tester, 'I');
        await iClickTheFloatingWindow(tester);
        await itIsPaused(tester);
        await iDragTheFloatingWindow(tester);
        await theFloatingWindowHasMoved(tester);
        await itIsPaused(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A click on the floating window pauses, dragging moves it''',
          success,
        );
      }
    });
    testWidgets('''Closing the floating window leaves the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Closing the floating window leaves the player''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await iPress(tester, 'I');
        await iHoverOverTheFloatingWindow(tester);
        await iTapTheButton(tester, 'close floating window');
        await thePlayerIsClosed(tester);
        await theWindowDoesNotFloat(tester);
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 30);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Closing the floating window leaves the player''',
          success,
        );
      }
    });
    testWidgets('''The next episode floats on''', (tester) async {
      var success = true;
      try {
        await beforeEach('''The next episode floats on''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await iPress(tester, 'I');
        await itPlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
        await thePlayerFloats(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next episode floats on''',
          success,
        );
      }
    });
    testWidgets('''Music does not float''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Music does not float''');
        await bddSetUp(tester);
        await iPlay(tester, 'album-1');
        await thereIsNoButton(tester, 'floating window');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Music does not float''',
          success,
        );
      }
    });
    testWidgets('''On a phone, going Home floats a video that plays''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a phone, going Home floats a video that plays''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iGoToThePhonesHome(tester);
        await thePlayerFloats(tester);
        await thePlayerIsFullScreen(tester);
        await theFloatingWindowsMiddleButtonIs(tester, 'Pause');
        await iUseTheFloatingWindows(tester, 'play/pause');
        await itIsPaused(tester);
        await theFloatingWindowsMiddleButtonIs(tester, 'Play');
        await iUseTheFloatingWindows(tester, '+10 s');
        await itIsAtSeconds(tester, 10);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a phone, going Home floats a video that plays''',
          success,
        );
      }
    });
    testWidgets('''On a phone, a paused video stays when going Home''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a phone, a paused video stays when going Home''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'play/pause');
        await iGoToThePhonesHome(tester);
        await theWindowDoesNotFloat(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a phone, a paused video stays when going Home''',
          success,
        );
      }
    });
    testWidgets(
        '''On a phone, growing the floating window back brings the controls''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a phone, growing the floating window back brings the controls''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iTapTheButton(tester, 'floating window');
        await thePlayerFloats(tester);
        await theFloatingWindowGrowsBack(tester);
        await thePlayerIsBackInItsWindow(tester);
        await thePlayerIsFullScreen(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a phone, growing the floating window back brings the controls''',
          success,
        );
      }
    });
    testWidgets('''On a phone, closing the floating window leaves the player''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''On a phone, closing the floating window leaves the player''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await iPlay(tester, 'movie-1');
        await iGoToThePhonesHome(tester);
        await theFloatingWindowIsClosed(tester);
        await thePlayerIsClosed(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''On a phone, closing the floating window leaves the player''',
          success,
        );
      }
    });
    testWidgets('''A phone without picture in picture has no button''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''A phone without picture in picture has no button''');
        await bddSetUp(tester);
        await theAppRunsOnA(tester, 'phone');
        await thePhoneCannotFloat(tester);
        await iPlay(tester, 'movie-1');
        await thereIsNoButton(tester, 'floating window');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''A phone without picture in picture has no button''',
          success,
        );
      }
    });
  });
}
