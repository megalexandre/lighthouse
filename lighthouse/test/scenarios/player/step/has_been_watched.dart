import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'episode-1'} has been watched
Future<void> hasBeenWatched(WidgetTester tester, String itemId) async {
  app.library.episodeItems = [
    for (final e in app.library.episodeItems)
      e.id == itemId
          ? e.copyWith(userData: const UserItemDataDto(played: true))
          : e,
  ];
}
