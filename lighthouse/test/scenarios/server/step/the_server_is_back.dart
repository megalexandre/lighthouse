import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When the server is back
///
/// It answers again; the app finds out on its next try.
Future<void> theServerIsBack(WidgetTester tester) async {
  app.library.failures.clear();
  app.serverUp = true;
}
