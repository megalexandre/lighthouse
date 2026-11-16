import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/user_item_data_dto.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/item_card.dart';
import 'package:jellyfin_flutter/features/reader/application/reader_controller.dart';
import 'package:jellyfin_flutter/features/reader/presentation/reader_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:jellyfin_flutter/widgets/error_retry.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  final comic = TestItems.testComic;

  String pageText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(ReaderScreen.pageText)).data!;

  /// Lets the reader's save timer run.
  Future<void> wait(WidgetTester tester) async {
    await tester.pump(ReaderController.saveDelay);
    await tester.pumpAndSettle();
  }

  Future<void> openComic(WidgetTester tester) async {
    await app.open(tester, Routes.item(comic.id));
    await tester.tap(find.byKey(ItemScreen.readButton));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsOneWidget);
  }

  testWidgets('a new book: "Read", opens on page 1', (tester) async {
    await app.open(tester, Routes.item(comic.id));
    expect(find.text('Read'), findsOneWidget);
    await tester.tap(find.byKey(ItemScreen.readButton));
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 1 of 5');
    expect(find.text(comic.name), findsOneWidget);
  });

  testWidgets('a started book: "Continue reading · 40%", opens where left', (
    tester,
  ) async {
    app.library.books = [
      comic.copyWith(
        userData: const UserItemDataDto(
          playbackPositionTicks: 20000,
          playedPercentage: 40,
        ),
      ),
    ];
    await app.open(tester, Routes.item(comic.id));
    expect(find.text('Continue reading · 40%'), findsOneWidget);
    await tester.tap(find.byKey(ItemScreen.readButton));
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 3 of 5');
  });

  testWidgets('swipe turns the page, and the place is saved', (tester) async {
    await openComic(tester);
    // From the right half, as one turns a page.
    final area = tester.getRect(find.byKey(ReaderScreen.pages));
    await tester.flingFrom(
      Offset(area.left + area.width * 0.8, area.center.dy),
      const Offset(-600, 0),
      1500,
    );
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 2 of 5');
    await wait(tester);
    expect(app.books.saved, [(comic.id, 10000)]);
  });

  testWidgets('pages turned quickly: one save, where the reader stops', (
    tester,
  ) async {
    await openComic(tester);
    for (var i = 0; i < 2; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle(); // a 250 ms slide each
    }
    expect(app.books.saved, isEmpty, reason: 'not before the delay');
    await wait(tester);
    expect(pageText(tester), 'Page 3 of 5');
    expect(app.books.saved, [(comic.id, 20000)]);
  });

  testWidgets('keys and edge taps turn pages; Home / End jump', (tester) async {
    await openComic(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 2 of 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 5 of 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 1 of 5');

    // Edge taps: the screen's edges, wherever the page sits.
    final screen = tester.getRect(find.byType(ReaderScreen));
    await tester.tapAt(
      Offset(screen.left + screen.width * 0.95, screen.center.dy),
    );
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 2 of 5');
    await tester.tapAt(
      Offset(screen.left + screen.width * 0.05, screen.center.dy),
    );
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 1 of 5');
    await wait(tester);
  });

  testWidgets('a tap in the middle hides and shows the bars', (tester) async {
    await openComic(tester);
    double opacity() =>
        tester.widget<AnimatedOpacity>(find.byKey(ReaderScreen.chrome)).opacity;
    final middle = tester.getRect(find.byType(ReaderScreen)).center;

    expect(opacity(), 1);
    await tester.tapAt(middle);
    await tester.pumpAndSettle();
    expect(opacity(), 0);
    await tester.tapAt(middle);
    await tester.pumpAndSettle();
    expect(opacity(), 1);
  });

  testWidgets('the last page marks the book read', (tester) async {
    await openComic(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    await wait(tester);
    expect(app.books.saved.last, (comic.id, 40000));
    expect(app.books.read, {comic.id: true});
  });

  testWidgets('back saves at once and returns to the book', (tester) async {
    await openComic(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ReaderScreen.backButton));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsNothing);
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(app.books.saved, [(comic.id, 10000)]);
  });

  group('EPUB', () {
    final novel = TestItems.testNovel;

    testWidgets('laid out for the sheet: a page per chapter, turned like '
        'the others; the place saved as the fraction read', (tester) async {
      await app.open(tester, Routes.read(novel.id));
      expect(pageText(tester), 'Page 1 of 3');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(pageText(tester), 'Page 2 of 3');
      await wait(tester);
      // 12.4 keeps an EPUB's place as a fraction of 10^7 ticks.
      final (id, position) = app.books.saved.single;
      expect(id, novel.id);
      expect(position, inExclusiveRange(0, novel.runTimeTicks!));

      // Opened again: there.
      await tester.tap(find.byKey(ReaderScreen.backButton));
      await tester.pumpAndSettle();
      app.library.books = [
        novel.copyWith(
          userData: UserItemDataDto(playbackPositionTicks: position),
        ),
      ];
      await app.open(tester, Routes.read(novel.id));
      expect(pageText(tester), 'Page 2 of 3');
    });

    testWidgets('halfway through the book: opens on the middle chapter', (
      tester,
    ) async {
      app.library.books = [
        novel.copyWith(
          userData: const UserItemDataDto(playbackPositionTicks: 5000000),
        ),
      ];
      await app.open(tester, Routes.read(novel.id));
      expect(pageText(tester), 'Page 2 of 3');
    });

    testWidgets('the window changes size: laid out again, same place', (
      tester,
    ) async {
      await app.open(tester, Routes.read(novel.id));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      final before = tester.getSize(find.byKey(ReaderScreen.pages));

      tester.view.physicalSize = const Size(900, 1400);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(ReaderScreen.pages)), isNot(before));
      expect(pageText(tester), 'Page 2 of 3');
    });
  });

  testWidgets('a download that fails can be retried', (tester) async {
    app.books.failures['file'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.read(comic.id));
    expect(find.byKey(ErrorRetry.retryButton), findsOneWidget);
    app.books.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(pageText(tester), 'Page 1 of 5');
  });

  testWidgets('mark as read from the book page', (tester) async {
    await app.open(tester, Routes.item(comic.id));
    expect(find.byTooltip('Mark as read'), findsOneWidget);
    await tester.tap(find.byKey(ItemScreen.watchedButton));
    await tester.pumpAndSettle();
    expect(app.books.read, {comic.id: true});
  });

  testWidgets('the Books library is a grid of books; one shows "% read"', (
    tester,
  ) async {
    app.library.books = [
      comic.copyWith(userData: const UserItemDataDto(playedPercentage: 60)),
      TestItems.testBook,
    ];
    await app.open(tester, Routes.library(TestItems.booksView.id));
    expect(find.byKey(ItemCard.keyFor(comic.id)), findsOneWidget);
    expect(find.text('60% read'), findsOneWidget);
    expect(find.text('Test Book'), findsOneWidget);
  });

  testWidgets('home: "Continue reading" with the book and how much is read', (
    tester,
  ) async {
    app.library.resumeBookItems = [
      comic.copyWith(userData: const UserItemDataDto(playedPercentage: 40)),
    ];
    await app.open(tester, Routes.home);
    expect(find.text('Continue reading'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(HomeScreen.resumeBooksRow),
        matching: find.text('40% read'),
      ),
      findsOneWidget,
    );
  });
}
