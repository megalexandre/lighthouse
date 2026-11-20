import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told no subtitle
///
/// Jellyfin's "none" is -1.
Future<void> theServerIsToldNoSubtitle(WidgetTester tester) async {
  expect(lastReport().subtitleStreamIndex, -1);
}
