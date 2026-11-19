import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: Given I am on the home screen
Future<void> iAmOnTheHomeScreen(WidgetTester tester) async {
  await app.open(tester, Routes.home);
}
