// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './hook/hooks.dart';
import './step/i_am_signed_in_as_a_new_user.dart';
import './step/i_see_the_libraries_and.dart';
import './step/i_see.dart';
import './step/i_open_the_library.dart';
import './step/the_library_shows.dart';
import './step/i_open.dart';
import './step/i_see_the_page_of.dart';
import './step/i_see_a_line.dart';
import './step/its_poster_comes_from_the_server.dart';
import './step/i_go_back.dart';
import './step/i_am_in_the_library.dart';
import './step/i_am_home.dart';
import './step/episodes_are_listed.dart';
import './step/i_open_episode.dart';
import './step/there_is_a_link_to_the_series.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Browsing''', () {
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

    testWidgets('''Home, the Movies library, the Test Movie, and back''',
        (tester) async {
      var success = true;
      try {
        await beforeEach(
            '''Home, the Movies library, the Test Movie, and back''');
        await bddSetUp(tester);
        await iSeeTheLibrariesAnd(tester, 'Movies', 'Shows', 'Music');
        await iSee(tester, 'Latest in Movies');
        await iOpenTheLibrary(tester, 'Movies');
        await theLibraryShows(tester, 'Test Movie (2020)');
        await theLibraryShows(tester, 'HEVC Movie (2021)');
        await iOpen(tester, 'Test Movie (2020)');
        await iSeeThePageOf(tester, 'Test Movie (2020)');
        await iSeeALine(tester, '2020 · 10s');
        await itsPosterComesFromTheServer(tester);
        await iGoBack(tester);
        await iAmInTheLibrary(tester);
        await iGoBack(tester);
        await iAmHome(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Home, the Movies library, the Test Movie, and back''',
          success,
        );
      }
    });
    testWidgets('''From the Shows library down to an episode''',
        (tester) async {
      var success = true;
      try {
        await beforeEach('''From the Shows library down to an episode''');
        await bddSetUp(tester);
        await iOpenTheLibrary(tester, 'Shows');
        await iOpen(tester, 'Test Show');
        await iSeeThePageOf(tester, 'Test Show');
        await iOpen(tester, 'Season 1');
        await iSee(tester, 'Episodes');
        await episodesAreListed(tester, 3);
        await iOpenEpisode(tester, 2);
        await iSeeALine(tester, 'S1:E2');
        await thereIsALinkToTheSeries(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''From the Shows library down to an episode''',
          success,
        );
      }
    });
  });
}
