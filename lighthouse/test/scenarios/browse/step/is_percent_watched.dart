import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Test Movie'} is {40} percent watched
///
/// So the server lists it to continue watching.
Future<void> isPercentWatched(
  WidgetTester tester,
  String name,
  num percent,
) async {
  app.library.resumeItems = [
    itemNamed(
      name,
    ).copyWith(userData: UserItemDataDto(playedPercentage: percent.toDouble())),
  ];
}
