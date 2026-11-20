import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open the page of {'movie-1'}
Future<void> iOpenThePageOf(WidgetTester tester, String itemId) async {
  await app.open(tester, Routes.item(itemId));
}
