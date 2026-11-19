import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the latest items cannot be loaded
///
/// Those of every library; the rest of home loads.
Future<void> theLatestItemsCannotBeLoaded(WidgetTester tester) async {
  app.library.failures['latest'] = unreachable;
}
