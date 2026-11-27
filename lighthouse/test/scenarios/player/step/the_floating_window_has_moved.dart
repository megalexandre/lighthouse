import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the floating window has moved
///
/// The window manager was asked to move it with the mouse.
Future<void> theFloatingWindowHasMoved(WidgetTester tester) async {
  expect(app.floating.drags, 1);
}
