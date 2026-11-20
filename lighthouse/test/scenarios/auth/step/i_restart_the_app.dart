import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I restart the app
///
/// A new run, with what the last one stored.
Future<void> iRestartTheApp(WidgetTester tester) async {
  await app.pump(tester);
}
