import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the player is let go
///
/// mpv is closed, not left running behind the page.
Future<void> thePlayerIsLetGo(WidgetTester tester) async {
  expect(app.engines.single.disposed, isTrue);
}
