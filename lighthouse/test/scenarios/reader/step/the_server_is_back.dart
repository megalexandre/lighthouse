import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When the server is back
///
/// The app's next connection check finds it (the checks back off, so a
/// minute covers several).
Future<void> theServerIsBack(WidgetTester tester) async {
  app.books.failures.clear();
  app.serverUp = true;
  await tester.pump(const Duration(minutes: 1));
  await tester.pumpAndSettle();
}
