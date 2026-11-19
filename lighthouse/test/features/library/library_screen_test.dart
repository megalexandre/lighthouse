import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/features/library/application/library_providers.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// What a user does in a library is in test/scenarios/browse/library.feature.
// Here: how the items are asked for, a page at a time, which no user sees.
void main() {
  final movies = Routes.library(TestItems.moviesView.id);

  testWidgets('one page on opening, then one per page scrolled to', (
    tester,
  ) async {
    final app = TestApp();
    app.library.movies = [
      for (var i = 0; i < 250; i++)
        BaseItemDto(id: 'm$i', name: 'Movie $i', type: BaseItemKind.movie),
    ];
    await app.open(tester, movies);
    expect(app.library.childrenCalls, [(0, LibraryController.pageSize)]);

    for (var i = 0; i < 50; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
    }
    expect(app.library.childrenCalls, [(0, 100), (100, 100), (200, 100)]);
  });
}
