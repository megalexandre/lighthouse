import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// The browsing pages laid out for a phone: what fits on its first screen.
// What a finger does on them is in test/scenarios/browse/touch.feature.
void main() {
  Rect rectOf(WidgetTester tester, Finder finder) => tester.getRect(finder);

  testWidgets('a library shows three posters across', (tester) async {
    final app = TestApp(theme: TestApp.prime);
    app.library.movies = [
      for (var i = 0; i < 9; i++)
        BaseItemDto(id: 'm$i', name: 'Movie $i', type: BaseItemKind.movie),
    ];
    await app.openOnPhone(tester, Routes.library(TestItems.moviesView.id));
    final tops = {
      for (var i = 0; i < 3; i++)
        rectOf(tester, find.byKey(ItemCard.keyFor('m$i'))).top,
    };
    expect(tops, hasLength(1), reason: 'the first three in one row');
    expect(
      rectOf(tester, find.byKey(ItemCard.keyFor('m3'))).top,
      greaterThan(tops.single),
    );
  });

  testWidgets('a home row shows about three posters', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    final row = find.byKey(HomeScreen.latestRow(TestItems.moviesView.id));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find
          .descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final card = rectOf(
      tester,
      find.descendant(of: row, matching: find.byType(ItemCard)).first,
    );
    expect(card.width, lessThan(TestWindows.phone.width / 3));
  });

  for (final sideways in [false, true]) {
    testWidgets('an item\'s Play is on the first screen'
        '${sideways ? ', on its side' : ''}', (tester) async {
      await TestApp(theme: TestApp.prime).openOnPhone(
        tester,
        Routes.item(TestItems.testMovie.id),
        sideways: sideways,
      );
      final window = sideways ? TestWindows.phoneSideways : TestWindows.phone;
      expect(
        rectOf(tester, find.byKey(ItemScreen.playButton)).bottom,
        lessThan(window.height),
      );
    });
  }

  testWidgets('on its side, the first row shows under the carousel', (
    tester,
  ) async {
    await TestApp(theme: TestApp.prime)
        .openOnPhone(tester, Routes.home, sideways: true);
    final row = find.byKey(HomeScreen.latestRow(TestItems.moviesView.id));
    expect(rectOf(tester, row).top, lessThan(TestWindows.phoneSideways.height));
  });
}
