import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the player of the one before is let go
///
/// Each item gets its own mpv; the last one's is closed.
Future<void> thePlayerOfTheOneBeforeIsLetGo(WidgetTester tester) async {
  expect(app.engines, hasLength(2));
  expect(app.engines.first.disposed, isTrue);
}
