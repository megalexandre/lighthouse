import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I go home
Future<void> iGoHome(WidgetTester tester) async {
  await app.open(tester, Routes.home);
}
