import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the subtitles are lifted above the controls
Future<void> theSubtitlesAreLiftedAboveTheControls(WidgetTester tester) async {
  expect(app.engine.subtitleLift, 96);
}
