import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'book-comic'} is {60} percent read
///
/// The server says so, and lists it to continue reading.
Future<void> isPercentRead(
  WidgetTester tester,
  String itemId,
  num percent,
) async {
  final data = UserItemDataDto(playedPercentage: percent.toDouble());
  changeBook(itemId, (b) => b.copyWith(userData: data));
  app.library.resumeBookItems = [
    for (final b in app.library.books)
      if (b.id == itemId) b,
  ];
}
