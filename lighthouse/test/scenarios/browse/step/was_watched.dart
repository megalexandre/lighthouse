import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Test Movie'} was watched
///
/// A movie or an episode.
Future<void> wasWatched(WidgetTester tester, String name) async {
  BaseItemDto watched(BaseItemDto i) =>
      i.copyWith(userData: const UserItemDataDto(played: true));
  changeMovie(name, watched);
  app.library.episodeItems = [
    for (final e in app.library.episodeItems) e.name == name ? watched(e) : e,
  ];
}
