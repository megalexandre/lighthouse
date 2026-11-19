import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the seasons cannot be loaded
///
/// A series' seasons; the series itself loads.
Future<void> theSeasonsCannotBeLoaded(WidgetTester tester) async {
  app.library.failures['seasons'] = unreachable;
}
