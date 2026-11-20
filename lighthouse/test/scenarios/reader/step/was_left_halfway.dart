import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'book-epub'} was left halfway
///
/// An EPUB's place on the server is the fraction read, of 10^7 ticks.
Future<void> wasLeftHalfway(WidgetTester tester, String itemId) async {
  changeBook(
    itemId,
    (b) => b.copyWith(
      userData: const UserItemDataDto(playbackPositionTicks: 5000000),
    ),
  );
}
