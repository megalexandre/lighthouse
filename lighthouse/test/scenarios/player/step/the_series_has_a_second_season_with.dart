import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';

import 'world.dart';

/// Usage: Given the series has a second season with {'Episode 4'}
///
/// One episode, the first of "Season 2", after the series' others.
Future<void> theSeriesHasASecondSeasonWith(
  WidgetTester tester,
  String name,
) async {
  app.library.episodeItems = [
    ...app.library.episodeItems,
    BaseItemDto(
      id: 'episode-4',
      name: name,
      type: BaseItemKind.episode,
      indexNumber: 1,
      parentIndexNumber: 2,
      seriesId: 'series-1',
      seriesName: 'Test Show',
      seasonId: 'season-2',
      seasonName: 'Season 2',
    ),
  ];
}
