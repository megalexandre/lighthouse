import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Test Comic'} was left on page {3}
///
/// As the server keeps a comic's place: 10000 ticks a page.
Future<void> wasLeftOnPage(WidgetTester tester, String name, num page) async {
  app.library.books = [
    for (final b in app.library.books)
      b.name == name
          ? b.copyWith(
              userData: UserItemDataDto(
                playbackPositionTicks: (page.toInt() - 1) * 10000,
              ),
            )
          : b,
  ];
}
