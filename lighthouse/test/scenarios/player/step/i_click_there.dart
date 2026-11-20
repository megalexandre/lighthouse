import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I click there
///
/// Where the mouse last went.
Future<void> iClickThere(WidgetTester tester) async {
  await tester.tapAt(mouseAt!);
  await tester.pump();
}
