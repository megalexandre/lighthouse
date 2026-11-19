import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server has {'book-comic'} as read
Future<void> theServerHasAsRead(WidgetTester tester, String itemId) async {
  expect(app.books.read[itemId], isTrue);
}
