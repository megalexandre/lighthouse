import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given another Jellyfin server answers at {'jellyfin.example.com'}
///
/// Not the one the other addresses reach: a different id.
Future<void> anotherJellyfinServerAnswersAt(
  WidgetTester tester,
  String address,
) async {
  app.servers.answers[address] = testServer.copyWith(
    id: 'another-server',
    name: 'Another Server',
  );
}
