import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I restart the app
///
/// A fresh app over the same stores: only what was saved survives.
Future<void> iRestartTheApp(WidgetTester tester) async {
  await app.pump(tester);
}
