import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then it is playing
Future<void> itIsPlaying(WidgetTester tester) async {
  expect(app.engine.playing, isTrue);
}
