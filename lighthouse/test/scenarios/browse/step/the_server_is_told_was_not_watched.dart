import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is told {'Test Movie'} was not watched
Future<void> theServerIsToldWasNotWatched(
  WidgetTester tester,
  String name,
) async {
  expect(app.playback.played, {itemNamed(name).id: false});
}
