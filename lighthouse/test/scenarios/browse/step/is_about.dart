import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';

import 'world.dart';

/// Usage: And {'Episode 2'} is about {'The second one.'}
///
/// Its overview, as the server has it.
Future<void> isAbout(WidgetTester tester, String name, String overview) async {
  _changeEpisode(name, (e) => e.copyWith(overview: overview));
}

void _changeEpisode(String name, BaseItemDto Function(BaseItemDto) change) {
  app.library.episodeItems = [
    for (final e in app.library.episodeItems) e.name == name ? change(e) : e,
  ];
}
