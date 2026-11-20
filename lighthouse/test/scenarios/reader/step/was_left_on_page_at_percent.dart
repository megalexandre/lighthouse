import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'book-comic'} was left on page {3} at {40} percent
///
/// As the server keeps a comic's place: 10000 ticks a page.
Future<void> wasLeftOnPageAtPercent(
  WidgetTester tester,
  String itemId,
  num page,
  num percent,
) async {
  changeBook(
    itemId,
    (b) => b.copyWith(
      userData: UserItemDataDto(
        playbackPositionTicks: (page.toInt() - 1) * 10000,
        playedPercentage: percent.toDouble(),
      ),
    ),
  );
}
