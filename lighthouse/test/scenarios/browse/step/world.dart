import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server and
/// library (see test/support/fakes.dart). Made by `the app is signed in`,
/// each scenario its own.
late TestApp app;

/// The scenario's tester, for the hooks: `Hooks.afterEach` closes the app
/// with it, and gets no tester of its own.
late WidgetTester tester;

/// How the fake library fails, in the steps that make it fail.
const unreachable = ServerUnreachable(testUrl);

/// The item of the fake library with that name.
BaseItemDto itemNamed(String name) => [
  ...TestItems.views,
  ...app.library.movies,
  ...app.library.books,
  app.library.show,
  TestItems.season1,
  ...app.library.episodeItems,
  TestItems.testAlbum,
  ...TestItems.tracks,
].firstWhere((i) => i.name == name);

/// The row of cards with that title.
Finder row(String title) =>
    find.byWidgetPredicate((w) => w is ItemRow && w.title == title);

/// Replaces the movie of that name in the fake library.
void changeMovie(String name, BaseItemDto Function(BaseItemDto) change) {
  app.library.movies = [
    for (final m in app.library.movies) m.name == name ? change(m) : m,
  ];
}

/// The card of the item with that name.
Finder cardOf(String name) => find.byKey(ItemCard.keyFor(itemNamed(name).id));

/// The mouse, once a step has put it on the screen.
TestGesture? mouse;

/// How much the card of that name is scaled (1: not lifted).
double cardScale(WidgetTester tester, String name) => tester
    .widget<AnimatedScale>(
      find.descendant(of: cardOf(name), matching: find.byType(AnimatedScale)),
    )
    .scale;

/// The row with that title, scrolled into view: home builds only the rows
/// on screen.
Future<Finder> rowOnScreen(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    row(title),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  return row(title);
}
