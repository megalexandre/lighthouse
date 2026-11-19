// The design system's MediaCard: what a card shows on top of its picture,
// and what hover and the keyboard do.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  final movies = Routes.library(TestItems.moviesView.id);
  final movie = TestItems.testMovie;

  testWidgets('watched: a check; started: the progress bar', (tester) async {
    app.library.movies = [
      movie.copyWith(userData: const UserItemDataDto(played: true)),
      TestItems.hevcMovie.copyWith(
        userData: const UserItemDataDto(playedPercentage: 30),
      ),
    ];
    await app.open(tester, movies);
    expect(
      find.descendant(
        of: find.byKey(ItemCard.keyFor(movie.id)),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(ItemCard.keyFor(TestItems.hevcMovie.id)),
        matching: find.byKey(ItemCard.progressBar),
      ),
      findsOneWidget,
    );
  });

  testWidgets('hover: the card lifts and a play button shows; it plays at '
      'once, the rest of the card opens the item', (tester) async {
    await app.open(tester, movies);
    expect(find.byKey(ItemCard.playKeyFor(movie.id)), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(
      location: tester.getCenter(find.byKey(ItemCard.keyFor(movie.id))),
    );
    await tester.pumpAndSettle();
    final scale = tester.widget<AnimatedScale>(
      find.descendant(
        of: find.byKey(ItemCard.keyFor(movie.id)),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(scale.scale, 1.04);

    await tester.tap(find.byKey(ItemCard.playKeyFor(movie.id)));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await mouse.removePointer();
  });

  testWidgets('reduced motion: it does not grow', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await app.open(tester, movies);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(
      location: tester.getCenter(find.byKey(ItemCard.keyFor(movie.id))),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ItemCard.playKeyFor(movie.id)), findsOneWidget);
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byKey(ItemCard.keyFor(movie.id)),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      1,
    );
    await mouse.removePointer();
  });

  testWidgets('a series has no play button: it opens', (tester) async {
    await app.open(tester, Routes.library(TestItems.showsView.id));
    final card = find.byKey(ItemCard.keyFor(TestItems.testShow.id));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(card));
    await tester.pumpAndSettle();
    expect(
      find.byKey(ItemCard.playKeyFor(TestItems.testShow.id)),
      findsNothing,
    );
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
    await mouse.removePointer();
  });
}
