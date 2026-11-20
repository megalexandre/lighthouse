import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given {'Episode 3'} has no number
///
/// The server does not know where in the season it comes.
Future<void> hasNoNumber(WidgetTester tester, String name) async {
  app.library.episodeItems = [
    for (final e in app.library.episodeItems)
      e.name == name ? e.copyWith(indexNumber: null) : e,
  ];
}
