import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the {'episodes'} cannot be loaded
///
/// A section of an item's page: a series' 'seasons', a season's
/// 'episodes', an album's 'tracks'. The item itself loads.
Future<void> theCannotBeLoaded(WidgetTester tester, String section) async {
  app.library.failures[section] = unreachable;
}
