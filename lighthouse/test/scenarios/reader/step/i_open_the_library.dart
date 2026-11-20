import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open the library {'view-books'}
Future<void> iOpenTheLibrary(WidgetTester tester, String viewId) async {
  await app.open(tester, Routes.library(viewId));
}
