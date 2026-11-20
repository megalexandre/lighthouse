import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the subtitles are at the bottom
Future<void> theSubtitlesAreAtTheBottom(WidgetTester tester) async {
  expect(app.engine.subtitleLift, 0);
}
