import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';
import 'world.dart';

/// Usage: And the server has {'Test Movie (2020)'} as watched
Future<void> theServerHasAsWatched(WidgetTester tester, String name) async {
  var played = false;
  await waitUntil(
    tester,
    () => played,
    reason: 'the server to have "$name" as watched',
    poll: () async => played = (await userDataOf(name))['Played'] == true,
  );
}
