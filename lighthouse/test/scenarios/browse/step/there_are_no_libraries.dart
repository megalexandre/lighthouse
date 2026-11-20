import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given there are no libraries
///
/// None the user may see on the server, so nothing to feature either.
Future<void> thereAreNoLibraries(WidgetTester tester) async {
  app.library
    ..viewItems = const []
    ..featuredItems = const [];
}
