import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And no stream is opened
Future<void> noStreamIsOpened(WidgetTester tester) async {
  expect(app.engines, isEmpty);
}
