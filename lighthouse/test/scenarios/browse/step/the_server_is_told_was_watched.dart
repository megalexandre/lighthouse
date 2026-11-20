import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server is told {'Test Movie'} was watched
Future<void> theServerIsToldWasWatched(WidgetTester tester, String name) async {
  expect(app.playback.played, {itemNamed(name).id: true});
}
