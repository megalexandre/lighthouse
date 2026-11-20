import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server has not been told the place
///
/// Not while pages are still turning.
Future<void> theServerHasNotBeenToldThePlace(WidgetTester tester) async {
  expect(app.books.saved, isEmpty);
}
