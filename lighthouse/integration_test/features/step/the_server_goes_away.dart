import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When the server goes away
///
/// The proxy stops passing anything on.
Future<void> theServerGoesAway(WidgetTester tester) async {
  proxy.up = false;
}
