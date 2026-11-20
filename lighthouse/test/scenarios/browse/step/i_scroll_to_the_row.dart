import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I scroll to the {'Latest in Movies'} row
Future<void> iScrollToTheRow(WidgetTester tester, String title) async {
  await tester.ensureVisible(row(title));
  await tester.pumpAndSettle();
}
