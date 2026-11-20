import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'movie-1'} was stopped at {64} seconds
///
/// The server keeps that place for it.
Future<void> wasStoppedAtSeconds(
  WidgetTester tester,
  String itemId,
  num seconds,
) async {
  app.library.movies = [
    for (final m in app.library.movies)
      m.id == itemId
          ? m.copyWith(
              userData: UserItemDataDto(
                playbackPositionTicks: (seconds * ticksPerSecond).toInt(),
              ),
            )
          : m,
  ];
}
