import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the clipboard holds {'first chapter'}
Future<void> theClipboardHolds(WidgetTester tester, String text) async {
  expect(clipboard, text);
}
