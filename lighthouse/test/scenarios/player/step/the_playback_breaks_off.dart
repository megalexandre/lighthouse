import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the playback breaks off
///
/// mpv loses the stream, as when the server goes away mid-film.
Future<void> thePlaybackBreaksOff(WidgetTester tester) async {
  app.engine.breakOff();
  await tester.pumpAndSettle();
}
