import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the video is {2160} pixels high
///
/// As the server describes the stream it plans.
Future<void> theVideoIsPixelsHigh(WidgetTester tester, num height) async {
  app.playback.videoHeight = height.toInt();
}
