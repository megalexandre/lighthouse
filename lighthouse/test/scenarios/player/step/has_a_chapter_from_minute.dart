import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/chapter_info.dart';

import 'world.dart';

/// Usage: Given {'movie-1'} has a chapter {'Storm'} from minute {5}
///
/// After an "Opening" one at the start.
Future<void> hasAChapterFromMinute(
  WidgetTester tester,
  String itemId,
  String name,
  num minute,
) async {
  app.library.movies = [
    for (final m in app.library.movies)
      m.id == itemId
          ? m.copyWith(
              chapters: [
                const ChapterInfo(name: 'Opening'),
                ChapterInfo(
                  startPositionTicks: (minute * 60 * ticksPerSecond).toInt(),
                  name: name,
                ),
              ],
            )
          : m,
  ];
}
