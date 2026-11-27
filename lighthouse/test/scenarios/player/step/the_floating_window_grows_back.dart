import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/floating_window.dart';

import 'world.dart';

/// Usage: When the floating window grows back
///
/// The user expanded the system's floating window (Android).
Future<void> theFloatingWindowGrowsBack(WidgetTester tester) async {
  app.floating.happen(FloatingEvent.expanded);
  await tester.pumpAndSettle();
}
