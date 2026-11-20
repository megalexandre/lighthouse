import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given mpv cannot open the stream
///
/// The server gives a stream; mpv fails on it.
Future<void> mpvCannotOpenTheStream(WidgetTester tester) async {
  app.engineOpenError = Exception('Failed to open');
}
