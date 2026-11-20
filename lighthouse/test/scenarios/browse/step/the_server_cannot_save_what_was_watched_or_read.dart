import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the server cannot save what was watched or read
Future<void> theServerCannotSaveWhatWasWatchedOrRead(
  WidgetTester tester,
) async {
  app.playback.failures['setPlayed'] = unreachable;
  app.books.failures['read'] = unreachable;
}
