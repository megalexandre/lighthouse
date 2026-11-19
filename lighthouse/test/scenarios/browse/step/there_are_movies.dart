import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';

import 'world.dart';

/// Usage: Given there are {250} movies
///
/// In place of the usual two: "Movie 000", "Movie 001"...
Future<void> thereAreMovies(WidgetTester tester, num count) async {
  app.library.movies = [
    for (var i = 0; i < count; i++)
      BaseItemDto(
        id: 'm$i',
        name: 'Movie ${i.toString().padLeft(3, '0')}',
        type: BaseItemKind.movie,
      ),
  ];
}
