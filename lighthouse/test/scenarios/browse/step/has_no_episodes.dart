import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given {'Season 1'} has no episodes
Future<void> hasNoEpisodes(WidgetTester tester, String season) async {
  app.library.episodeItems = const [];
}
