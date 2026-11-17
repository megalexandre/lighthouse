import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/user_item_data_dto.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/item_card.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:jellyfin_flutter/widgets/error_retry.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  Finder inRow(Key row, Finder finder) =>
      find.descendant(of: find.byKey(row), matching: finder);

  testWidgets('libraries, then the latest of each', (tester) async {
    await app.open(tester, Routes.home);

    for (final view in TestItems.views) {
      expect(
        inRow(HomeScreen.viewsRow, find.byKey(ItemCard.keyFor(view.id))),
        findsOneWidget,
      );
    }
    expect(find.text('Latest in Movies'), findsOneWidget);
    expect(
      inRow(
        HomeScreen.latestRow(TestItems.moviesView.id),
        find.text('Test Movie'),
      ),
      findsOneWidget,
    );
    expect(find.text('Latest in Shows'), findsOneWidget);
    expect(find.text('Latest in Music'), findsOneWidget);
    expect(find.text('Test Album'), findsOneWidget);
  });

  testWidgets('empty rows are left out', (tester) async {
    await app.open(tester, Routes.home);
    expect(find.byKey(HomeScreen.resumeRow), findsOneWidget);
    expect(find.text('Continue watching'), findsNothing);
    expect(find.text('Next up'), findsNothing);
  });

  testWidgets('continue watching and next up', (tester) async {
    final [e1, e2, _] = TestItems.episodes;
    app.library
      ..resumeItems = [
        TestItems.testMovie.copyWith(
          userData: const UserItemDataDto(playedPercentage: 40),
        ),
      ]
      ..nextUpItems = [e2];
    await app.open(tester, Routes.home);

    expect(find.text('Continue watching'), findsOneWidget);
    expect(
      inRow(HomeScreen.resumeRow, find.byKey(ItemCard.progressBar)),
      findsOneWidget,
    );
    expect(find.text('Next up'), findsOneWidget);
    expect(
      inRow(HomeScreen.nextUpRow, find.text('Test Show · S1:E2')),
      findsOneWidget,
    );
    expect(find.text(e1.name), findsNothing);
  });

  testWidgets('a failing row says so; the others still show', (tester) async {
    app.library.failures['latest'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.home);

    expect(find.byKey(HomeScreen.viewsRow), findsOneWidget);
    expect(find.text(const ServerUnreachable(testUrl).message), findsWidgets);

    app.library.failures.clear();
    await tester.tap(
      inRow(
        HomeScreen.latestRow(TestItems.moviesView.id),
        find.byKey(ErrorRetry.retryButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      inRow(
        HomeScreen.latestRow(TestItems.moviesView.id),
        find.text('Test Movie'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('libraries failing: error and retry', (tester) async {
    app.library.failures['views'] = const ServerError(
      'HTTP 500',
      statusCode: 500,
    );
    await app.open(tester, Routes.home);
    expect(find.text('The server answered with error 500.'), findsOneWidget);

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(find.byKey(HomeScreen.viewsRow), findsOneWidget);
  });

  testWidgets('a library opens as a grid; Back returns home', (tester) async {
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(ItemCard.keyFor(TestItems.moviesView.id)));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.text('HEVC Movie'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
