import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: Given nothing answers at {'http://nowhere:8096'}
Future<void> nothingAnswersAt(WidgetTester tester, String address) async {
  app.servers.probeFailure = ServerUnreachable(address);
}
