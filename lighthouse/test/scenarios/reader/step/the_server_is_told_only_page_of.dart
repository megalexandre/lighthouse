import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is told only page {3} of {'book-comic'}
///
/// One save, of that page (10000 ticks a page).
Future<void> theServerIsToldOnlyPageOf(
  WidgetTester tester,
  num page,
  String itemId,
) async {
  expect(app.books.saved, [(itemId, (page.toInt() - 1) * 10000)]);
}
