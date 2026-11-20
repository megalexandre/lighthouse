import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: Given nothing answers at {'http://nowhere:8096'}
///
/// Only there: other addresses still reach the test server.
Future<void> nothingAnswersAt(WidgetTester tester, String address) async {
  app.servers.answers[address] = ServerUnreachable(address);
}
