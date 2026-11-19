import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart' as world;

/// Usage: Given the app is started for the first time
///
/// Nothing stored: no server, nobody signed in.
Future<void> theAppIsStartedForTheFirstTime(WidgetTester tester) async {
  final app = world.app = TestApp();
  await app.pump(tester);
}
