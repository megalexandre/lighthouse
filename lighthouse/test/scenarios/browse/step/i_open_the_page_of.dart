import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open the page of {'Test Movie'}
///
/// Straight to it, as from its card.
Future<void> iOpenThePageOf(WidgetTester tester, String name) async {
  await app.open(tester, Routes.item(itemNamed(name).id));
}
