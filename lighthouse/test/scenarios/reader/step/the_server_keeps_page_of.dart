import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps page {3} of {'book-comic'}
///
/// On 12.4's scale for a comic: 10000 ticks a page, from 0.
Future<void> theServerKeepsPageOf(
  WidgetTester tester,
  num page,
  String itemId,
) async {
  final saves = [
    for (final (id, ticks) in app.books.saved)
      if (id == itemId) ticks,
  ];
  expect(saves, isNotEmpty);
  expect(saves.last, (page.toInt() - 1) * 10000);
}
