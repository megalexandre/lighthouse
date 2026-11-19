import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open the {'Movies'} library
///
/// Straight to it, as from its card on home.
Future<void> iOpenTheLibrary(WidgetTester tester, String name) async {
  await app.open(tester, Routes.library(itemNamed(name).id));
}
