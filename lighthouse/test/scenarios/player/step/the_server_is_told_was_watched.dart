import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is told {'movie-1'} was watched
Future<void> theServerIsToldWasWatched(
  WidgetTester tester,
  String itemId,
) async {
  expect(app.playback.played, {itemId: true});
}
