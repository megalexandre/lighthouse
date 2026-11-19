import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the episode plays to its end
Future<void> theEpisodePlaysToItsEnd(WidgetTester tester) async {
  app.engine.finish();
  await tester.pumpAndSettle();
}
