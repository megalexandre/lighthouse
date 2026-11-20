// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/seconds_have_played.dart';
import './step/the_playback_breaks_off.dart';
import './step/the_player_is_still_open.dart';
import './step/i_see.dart';
import './step/the_server_is_told_stopped_at_seconds.dart';
import './step/i_tap_the_button.dart';
import './step/it_started_at_seconds.dart';
import './step/i_do_not_see.dart';
import './step/the_server_cannot_be_told_playback_stopped.dart';
import './step/i_press.dart';
import './step/the_server_has_not_been_told_where_it_stopped.dart';
import './step/the_server_is_back.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Playing while the server goes away''', () {
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

    testWidgets('''Playback that breaks off offers to resume where it was''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Playback that breaks off offers to resume where it was''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 30);
        await thePlaybackBreaksOff(tester);
        await thePlayerIsStillOpen(tester);
        await iSee(tester, 'Resume from 0:30');
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 30);
        await iTapTheButton(tester, 'resume after break');
        await itStartedAtSeconds(tester, 30);
        await iDoNotSee(tester, 'Resume from 0:30');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Playback that breaks off offers to resume where it was''',
          success,
        );
      }
    });
    testWidgets(
        '''Where it stopped while the server was away reaches it later''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Where it stopped while the server was away reaches it later''');
        await bddSetUp(tester);
        await iPlay(tester, 'movie-1');
        await secondsHavePlayed(tester, 42);
        await theServerCannotBeToldPlaybackStopped(tester);
        await iPress(tester, 'Esc');
        await theServerHasNotBeenToldWhereItStopped(tester);
        await theServerIsBack(tester);
        await theServerIsToldStoppedAtSeconds(tester, 'movie-1', 42);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Where it stopped while the server was away reaches it later''',
          success,
        );
      }
    });
  });
}
