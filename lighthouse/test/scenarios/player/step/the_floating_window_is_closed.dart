import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/floating_window.dart';

import 'world.dart';

/// Usage: When the floating window is closed
///
/// With the X of the system's floating window (Android).
Future<void> theFloatingWindowIsClosed(WidgetTester tester) async {
  app.floating.happen(FloatingEvent.closed);
  await tester.pumpAndSettle();
}
