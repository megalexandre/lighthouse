// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_signed_in.dart';
import './step/i_play.dart';
import './step/the_episode_reaches_its_last_seconds.dart';
import './step/i_see_the_up_next_card_for.dart';
import './step/i_tap_watch_now.dart';
import './step/is_playing.dart';
import './step/i_hide_the_up_next_card.dart';
import './step/the_episode_plays_to_its_end.dart';
import './step/next_episode_autoplay_is_off.dart';
import './step/i_do_not_see_the_up_next_card.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Up next''', () {
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

    testWidgets('''The next episode is offered in the last seconds''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''The next episode is offered in the last seconds''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await theEpisodeReachesItsLastSeconds(tester, 6);
        await iSeeTheUpNextCardFor(tester, 'S1:E2 · Episode 2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''The next episode is offered in the last seconds''',
          success,
        );
      }
    });
    testWidgets('''Watch now plays the next episode at once''', (tester) async {
      var success = true;
      try {
        await beforeEach('''Watch now plays the next episode at once''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await theEpisodeReachesItsLastSeconds(tester, 6);
        await iTapWatchNow(tester);
        await isPlaying(tester, 'episode-2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Watch now plays the next episode at once''',
          success,
        );
      }
    });
    testWidgets('''Hidden, the next episode still plays at the end''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''Hidden, the next episode still plays at the end''');
        await bddSetUp(tester);
        await iPlay(tester, 'episode-1');
        await theEpisodeReachesItsLastSeconds(tester, 6);
        await iHideTheUpNextCard(tester);
        await theEpisodePlaysToItsEnd(tester);
        await isPlaying(tester, 'episode-2');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Hidden, the next episode still plays at the end''',
          success,
        );
      }
    });
    testWidgets('''With autoplay off, nothing is offered''', (tester) async {
      var success = true;
      try {
        await beforeEach('''With autoplay off, nothing is offered''');
        await bddSetUp(tester);
        await nextEpisodeAutoplayIsOff(tester);
        await iPlay(tester, 'episode-1');
        await theEpisodeReachesItsLastSeconds(tester, 6);
        await iDoNotSeeTheUpNextCard(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''With autoplay off, nothing is offered''',
          success,
        );
      }
    });
  });
}
