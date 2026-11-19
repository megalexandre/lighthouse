import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:lighthouse/router.dart';
import 'package:lighthouse/widgets/error_retry.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(SearchScreen.field), text);
    await tester.pump(SearchScreen.debounce);
    await tester.pumpAndSettle();
  }

  testWidgets('the search button and Ctrl+F open it', (tester) async {
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(HomeScreen.searchButton));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('results by kind', (tester) async {
    await app.open(tester, Routes.search);
    await search(tester, 'test');

    Finder row(BaseItemKind kind, String name) => find.descendant(
      of: find.byKey(SearchScreen.row(kind)),
      matching: find.text(name),
    );
    expect(row(BaseItemKind.movie, 'Test Movie'), findsOneWidget);
    expect(row(BaseItemKind.series, 'Test Show'), findsOneWidget);
    expect(row(BaseItemKind.musicAlbum, 'Test Album'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Shows'), findsOneWidget);
    expect(find.text('Albums'), findsOneWidget);
    expect(find.text('Songs'), findsNothing); // no track is named "test"
  });

  testWidgets('typing asks once, after the pause', (tester) async {
    await app.open(tester, Routes.search);
    for (final text in ['e', 'ep', 'epi']) {
      await tester.enterText(find.byKey(SearchScreen.field), text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(SearchScreen.debounce);
    await tester.pumpAndSettle();
    expect(app.library.searches, ['epi']);
    expect(find.byKey(SearchScreen.row(BaseItemKind.episode)), findsOneWidget);
  });

  testWidgets('nothing found', (tester) async {
    await app.open(tester, Routes.search);
    await search(tester, 'zzz');
    expect(find.byKey(SearchScreen.noResults), findsOneWidget);
  });

  testWidgets('a failing search can be retried', (tester) async {
    app.library.failures['search'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.search);
    await search(tester, 'test');
    expect(
      find.text(const ServerUnreachable(testUrl).describe(en)),
      findsOneWidget,
    );

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(find.text('Test Movie'), findsOneWidget);
  });

  testWidgets('a result opens its page', (tester) async {
    await app.open(tester, Routes.search);
    await search(tester, 'movie');
    await tester.tap(find.byKey(ItemCard.keyFor(TestItems.testMovie.id)));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
  });
}
