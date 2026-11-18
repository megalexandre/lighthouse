import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import '../../support/app.dart';
import 'navigation.dart';
import 'world.dart' as world;

/// Usage: When I play episode {'Test Show S01E01'} of {'Test Show'}
///
/// Home → Shows → the show → Season 1 → the episode's page → Play.
Future<void> iPlayEpisodeOf(
  WidgetTester tester,
  String episode,
  String show,
) async {
  await openFromLibrary(tester, 'Shows', show);
  final season = onScreen(ItemScreen, find.text('Season 1'));
  await waitFor(tester, season);
  await tapOn(tester, season);
  // Listed as "1. Test Show S01E01".
  final row = onScreen(ItemScreen, find.textContaining(episode));
  await waitFor(tester, row);
  await tapOn(tester, row.first);
  world.item = episode;
  final play = onScreen(ItemScreen, find.byKey(ItemScreen.playButton));
  await waitFor(tester, play);
  await tapOn(tester, play);
  await waitFor(tester, find.byKey(PlayerScreen.positionText));
}
