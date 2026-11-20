import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: When I open an episode
///
/// Its page.
Future<void> iOpenAnEpisode(WidgetTester tester) async {
  await app.open(tester, Routes.item(TestItems.episodes.first.id));
}
