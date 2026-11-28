import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And nothing rubbed
Future<void> nothingRubbed(WidgetTester tester) async {
  expect(app.pageSounds.rubs, isEmpty);
}
