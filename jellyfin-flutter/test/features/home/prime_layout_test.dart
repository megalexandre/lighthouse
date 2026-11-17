// The Prime theme's components (assets/themes/prime.json, `components`):
// the floating top bar with the libraries as tabs, the home carousel and
// the rows' arrows. The other screens' tests use Lanterna's plain layout.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/features/auth/presentation/login_screen.dart';
import 'package:jellyfin_flutter/features/home/presentation/floating_top_bar.dart';
import 'package:jellyfin_flutter/features/home/presentation/hero_carousel.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/card_popover.dart';
import 'package:jellyfin_flutter/features/library/presentation/item_card.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/search/presentation/search_screen.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:jellyfin_flutter/widgets/row_arrows.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp(theme: 'builtin:prime.json'));

  /// The carousel's current title (in capitals).
  Finder heroTitle(String name) => find.descendant(
    of: find.byKey(HomeScreen.hero),
    matching: find.text(name.toUpperCase()),
  );

  FloatingTopBar bar(WidgetTester tester) =>
      tester.widget<FloatingTopBar>(find.byType(FloatingTopBar));

  testWidgets('home: the bar with a tab per library, the carousel, no '
      'libraries row', (tester) async {
    await app.open(tester, Routes.home);
    expect(find.byKey(FloatingTopBar.homeTab), findsOneWidget);
    for (final view in TestItems.views) {
      expect(find.byKey(FloatingTopBar.tab(view.id)), findsOneWidget);
    }
    expect(find.byKey(HomeScreen.viewsRow), findsNothing);
    expect(heroTitle(TestItems.testMovie.name), findsOneWidget);
    // Over the carousel the bar is see-through.
    expect(bar(tester).solid, isFalse);
    expect(bar(tester).activeView, isNull);
  });

  testWidgets('carousel: arrows, dots, and on by itself every 8 s', (
    tester,
  ) async {
    await app.open(tester, Routes.home);
    final [first, second, ...] = [...app.library.movies, TestItems.testShow];
    await tester.tap(find.byKey(HeroCarousel.nextButton));
    await tester.pumpAndSettle();
    expect(heroTitle(second.name), findsOneWidget);
    await tester.tap(find.byKey(HeroCarousel.previousButton));
    await tester.pumpAndSettle();
    expect(heroTitle(first.name), findsOneWidget);
    await tester.tap(find.byKey(HeroCarousel.dot(2)));
    await tester.pumpAndSettle();
    expect(heroTitle(TestItems.testShow.name), findsOneWidget);
    // A series: its episodes, not Play.
    expect(find.text('Episodes'), findsOneWidget);

    await tester.pump(HeroCarousel.interval);
    await tester.pumpAndSettle();
    expect(heroTitle(first.name), findsOneWidget); // Wrapped around.
  });

  testWidgets('carousel: Play plays a movie; More info opens it', (
    tester,
  ) async {
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(HeroCarousel.infoButton));
    await tester.pumpAndSettle();
    expect(find.byType(ItemScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(HeroCarousel.playButton));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });

  testWidgets('a tab opens its library, the bar kept and its tab on; Home '
      'comes back', (tester) async {
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(FloatingTopBar.tab(TestItems.moviesView.id)));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(bar(tester).activeView, TestItems.moviesView.id);
    expect(bar(tester).solid, isTrue);
    expect(find.text(TestItems.testMovie.name), findsOneWidget);

    await tester.tap(find.byKey(FloatingTopBar.homeTab));
    await tester.pumpAndSettle();
    expect(find.byKey(HomeScreen.hero), findsOneWidget);
  });

  testWidgets('scrolling: the bar turns solid', (tester) async {
    await app.open(tester, Routes.home);
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(bar(tester).solid, isTrue);
  });

  testWidgets('search opens into a field; Enter searches', (tester) async {
    await app.open(tester, Routes.home);
    expect(find.byKey(FloatingTopBar.searchField), findsNothing);
    await tester.tap(find.byKey(FloatingTopBar.searchButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(FloatingTopBar.searchField), 'test');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(SearchScreen.field)).controller!.text,
      'test',
    );
  });

  testWidgets('profile menu: light theme, Settings, Sign out', (tester) async {
    await app.open(tester, Routes.home);
    await tester.tap(find.byKey(FloatingTopBar.profileButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FloatingTopBar.themeItem));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomeScreen))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(FloatingTopBar.profileButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FloatingTopBar.settingsItem));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(FloatingTopBar.profileButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FloatingTopBar.signOutItem));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a long row: arrows page through it, each only where there '
      'is more', (tester) async {
    app.library.movies = [
      for (var i = 0; i < 24; i++)
        BaseItemDto(id: 'movie-$i', name: 'Movie $i', type: BaseItemKind.movie),
    ];
    await app.open(tester, Routes.home);
    final row = find.byKey(HomeScreen.latestRow(TestItems.moviesView.id));
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    Finder inRow(Key key) =>
        find.descendant(of: row, matching: find.byKey(key));
    expect(inRow(RowArrows.previousKey), findsNothing);
    expect(inRow(RowArrows.nextKey), findsOneWidget);

    await tester.tap(inRow(RowArrows.nextKey));
    await tester.pumpAndSettle();
    expect(inRow(RowArrows.previousKey), findsOneWidget);
    await tester.tap(inRow(RowArrows.previousKey));
    await tester.pumpAndSettle();
    expect(inRow(RowArrows.previousKey), findsNothing);
  });

  testWidgets('Lanterna keeps its plain layout', (tester) async {
    app = TestApp();
    await app.open(tester, Routes.home);
    expect(find.byType(FloatingTopBar), findsNothing);
    expect(find.byKey(HomeScreen.hero), findsNothing);
    expect(find.byKey(HomeScreen.viewsRow), findsOneWidget);
    expect(find.byKey(RowArrows.nextKey), findsNothing);
  });

  group('a card under the mouse opens its panel', () {
    final movie = TestItems.testMovie;
    Finder card() => find.byKey(ItemCard.keyFor(movie.id));

    Future<TestGesture> restOn(WidgetTester tester, Finder target) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(target));
      await tester.pump();
      return mouse;
    }

    Future<void> openMovies(WidgetTester tester) async {
      await app.open(tester, Routes.library(TestItems.moviesView.id));
    }

    testWidgets('after a moment: the panel with the whole item; the card '
        'itself does not grow', (tester) async {
      app.library.movies = [
        movie.copyWith(overview: 'A movie made for tests.'),
      ];
      await openMovies(tester);
      final mouse = await restOn(tester, card());
      await tester.pump(ItemCard.expandDelay ~/ 2);
      expect(find.byKey(CardPopover.panel), findsNothing); // Not yet.
      await tester.pump(ItemCard.expandDelay);
      await tester.pumpAndSettle();
      expect(find.byKey(CardPopover.panel), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(CardPopover.panel),
          matching: find.text('A movie made for tests.'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<AnimatedScale>(
              find.descendant(of: card(), matching: find.byType(AnimatedScale)),
            )
            .scale,
        1,
      );

      // Off it: closed.
      await mouse.moveTo(const Offset(1500, 1100));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(find.byKey(CardPopover.panel), findsNothing);
    });

    testWidgets('Play plays; details opens; watched marks it', (tester) async {
      await openMovies(tester);
      final mouse = await restOn(tester, card());
      await tester.pump(ItemCard.expandDelay);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CardPopover.watchedButton));
      await tester.pumpAndSettle();
      expect(app.playback.played, {movie.id: true});

      await tester.tap(find.byKey(CardPopover.infoButton));
      await tester.pumpAndSettle();
      expect(find.byType(ItemScreen), findsOneWidget);
      expect(find.byKey(CardPopover.panel), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // The mouse comes back onto the card.
      await mouse.moveTo(const Offset(1500, 1100));
      await tester.pump();
      await mouse.moveTo(tester.getCenter(card()));
      await tester.pump(ItemCard.expandDelay);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CardPopover.playButton));
      await tester.pumpAndSettle();
      expect(find.byType(PlayerScreen), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets('Lanterna: the card lifts, no panel', (tester) async {
      app = TestApp();
      await openMovies(tester);
      await restOn(tester, card());
      await tester.pump(ItemCard.expandDelay * 2);
      await tester.pumpAndSettle();
      expect(find.byKey(CardPopover.panel), findsNothing);
      expect(find.byKey(ItemCard.playKeyFor(movie.id)), findsOneWidget);
    });
  });
}
