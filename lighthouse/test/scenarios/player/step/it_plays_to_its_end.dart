import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And it plays to its end
Future<void> itPlaysToItsEnd(WidgetTester tester) async {
  app.engine.finish();
  await tester.pumpAndSettle();
}
