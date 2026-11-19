import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the library cannot be loaded
///
/// No page of its items, the first or the next, comes.
Future<void> theLibraryCannotBeLoaded(WidgetTester tester) async {
  app.library.failures['children'] = unreachable;
}
