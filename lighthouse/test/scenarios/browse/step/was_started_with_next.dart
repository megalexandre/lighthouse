import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Test Show'} was started, with {'Episode 2'} next
///
/// An episode before it was watched to the end, so the server counts part
/// of the series as watched.
Future<void> wasStartedWithNext(
  WidgetTester tester,
  String series,
  String next,
) async {
  app.library
    ..show = itemNamed(series)
        .copyWith(userData: const UserItemDataDto(playedPercentage: 33))
    ..nextUpItems = [itemNamed(next)];
}
