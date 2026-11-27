import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the video is {1920} by {800} pixels
///
/// As the server describes the stream it plans.
Future<void> theVideoIsByPixels(
  WidgetTester tester,
  num width,
  num height,
) async {
  app.playback
    ..videoWidth = width.toInt()
    ..videoHeight = height.toInt();
}
