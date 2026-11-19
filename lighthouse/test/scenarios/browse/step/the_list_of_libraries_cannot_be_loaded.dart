import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the list of libraries cannot be loaded
///
/// As if the server were gone when home asks for them.
Future<void> theListOfLibrariesCannotBeLoaded(WidgetTester tester) async {
  app.library.failures['views'] = unreachable;
}
