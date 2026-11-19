import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/application/library_providers.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:lighthouse/router.dart';
import 'package:lighthouse/widgets/error_retry.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  final movies = Routes.library(TestItems.moviesView.id);

  List<BaseItemDto> manyMovies(int n) => [
    for (var i = 0; i < n; i++)
      BaseItemDto(
        id: 'm$i',
        name: 'Movie ${i.toString().padLeft(3, '0')}',
        type: BaseItemKind.movie,
      ),
  ];

  /// Scrolls the grid to its end, letting pages load on the way.
  Future<void> scrollToEnd(WidgetTester tester) async {
    for (var i = 0; i < 50; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('the library name and its items', (tester) async {
    await app.open(tester, movies);
    expect(find.text('Movies'), findsOneWidget); // app bar
    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.text('2020'), findsOneWidget);
    expect(find.text('HEVC Movie'), findsOneWidget);
    expect(app.library.childrenCalls, [(0, LibraryController.pageSize)]);
  });

  testWidgets('pages load while scrolling, until all are there', (
    tester,
  ) async {
    app.library.movies = manyMovies(250);
    await app.open(tester, movies);
    expect(app.library.childrenCalls, hasLength(1));
    expect(find.text('Movie 249'), findsNothing);

    await scrollToEnd(tester);
    expect(find.text('Movie 249'), findsOneWidget);
    expect(app.library.childrenCalls, [(0, 100), (100, 100), (200, 100)]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a page that fails to load can be retried', (tester) async {
    app.library.movies = manyMovies(150);
    await app.open(tester, movies);

    app.library.failures['children'] = const ServerUnreachable(testUrl);
    await scrollToEnd(tester);
    expect(find.byKey(ErrorRetry.retryButton), findsOneWidget);
    expect(find.text('Movie 149'), findsNothing);

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    await scrollToEnd(tester);
    expect(find.text('Movie 149'), findsOneWidget);
  });

  testWidgets('an empty library says so', (tester) async {
    app.library.movies = [];
    await app.open(tester, movies);
    expect(find.byKey(LibraryScreen.emptyText), findsOneWidget);
  });

  testWidgets('failing to open: error and retry', (tester) async {
    app.library.failures['children'] = const ServerUnreachable(testUrl);
    await app.open(tester, movies);
    expect(
      find.text(const ServerUnreachable(testUrl).describe(en)),
      findsOneWidget,
    );

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(find.text('Test Movie'), findsOneWidget);
  });

  testWidgets('a movie opens its detail page', (tester) async {
    await app.open(tester, movies);
    await tester.tap(find.byKey(ItemCard.keyFor(TestItems.testMovie.id)));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
  });
}
