import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the item cannot be loaded
///
/// Its page has nothing to show.
Future<void> theItemCannotBeLoaded(WidgetTester tester) async {
  app.library.failures['item'] = unreachable;
}
