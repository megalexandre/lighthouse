import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then no subtitle is shown
Future<void> noSubtitleIsShown(WidgetTester tester) async {
  expect(app.engine.subtitleTrack.id, 'no');
}
