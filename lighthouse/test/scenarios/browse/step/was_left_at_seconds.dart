import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Episode 1'} was left at {30} seconds
///
/// Nothing of its series watched to the end: the series counts as not
/// watched, the episode as in progress, and next up.
Future<void> wasLeftAtSeconds(
  WidgetTester tester,
  String episode,
  num seconds,
) async {
  app.library.nextUpItems = [
    itemNamed(episode).copyWith(
      userData: UserItemDataDto(
        playbackPositionTicks: (seconds * 10000000).toInt(),
      ),
    ),
  ];
}
