import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And it plays to its end without a frame
///
/// As with the screen off.
Future<void> itPlaysToItsEndWithoutAFrame(WidgetTester tester) async {
  app.engine.finish();
  // The futures run; no pump, so no frame is drawn.
  for (var i = 0; i < 20; i++) {
    await tester.idle();
  }
}
