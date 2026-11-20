import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given {'Test Show'} has {2} seasons
///
/// As the server counts them on the series.
Future<void> hasSeasons(WidgetTester tester, String name, num count) async {
  app.library.show = app.library.show.copyWith(childCount: count.toInt());
}
