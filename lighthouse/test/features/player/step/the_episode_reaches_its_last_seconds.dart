import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the episode reaches its last {6} seconds
Future<void> theEpisodeReachesItsLastSeconds(
  WidgetTester tester,
  int seconds,
) async {
  final engine = app.engine;
  engine.advance(
    engine.duration - Duration(seconds: seconds) - engine.position,
  );
  // The position reaches the screen by stream: a frame later.
  await tester.pump();
  await tester.pump();
}
