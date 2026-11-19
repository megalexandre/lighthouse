import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: Given I am on the search screen
Future<void> iAmOnTheSearchScreen(WidgetTester tester) async {
  await app.open(tester, Routes.search);
}
