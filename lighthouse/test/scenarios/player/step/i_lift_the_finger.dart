import 'package:flutter_test/flutter_test.dart';

import 'world.dart' as world;

/// Usage: When I lift the finger
///
/// The one `I slide a finger along the seek bar` put down.
Future<void> iLiftTheFinger(WidgetTester tester) async {
  await world.finger!.up();
  world.finger = null;
  await tester.pumpAndSettle();
}
