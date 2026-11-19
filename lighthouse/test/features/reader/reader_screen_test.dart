import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/reader/application/reader_controller.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:lighthouse/widgets/error_retry.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/epub.dart';
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

  group('contents, bookmarks, display', () {
    final novel = TestItems.testNovel;

    Color desk(WidgetTester tester) => tester
        .widget<Scaffold>(
          find.descendant(
            of: find.byType(ReaderScreen),
            matching: find.byType(Scaffold),
          ),
        )
        .backgroundColor!;

    testWidgets('the contents list the chapters; one jumps there', (
      tester,
    ) async {
      await app.open(tester, Routes.read(novel.id));
      await tester.tap(find.byKey(ReaderScreen.contentsButton));
      await tester.pumpAndSettle();
      expect(find.text('Chapter One'), findsOneWidget);
      expect(find.text('Chapter Two'), findsOneWidget);
      await tester.tap(find.text('Chapter Three'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      expect(pageText(tester), 'Page 3 of 3');
      // The keys are the book's again.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(pageText(tester), 'Page 2 of 3');
    });

    testWidgets('a book without contents says so', (tester) async {
      await openComic(tester);
      await tester.tap(find.byKey(ReaderScreen.contentsButton));
      await tester.pumpAndSettle();
      expect(find.text('This book has no table of contents.'), findsOneWidget);
    });

    testWidgets('bookmark a page: kept, listed, and removed', (tester) async {
      await app.open(tester, Routes.read(novel.id));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ReaderScreen.bookmarkButton));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove bookmark'), findsOneWidget);
      final [saved] = app.books.bookmarksOf[novel.id]!;

      // Elsewhere, the button is off; the list goes back there.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Bookmark this page'), findsOneWidget);
      await tester.tap(find.byKey(ReaderScreen.contentsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ReaderScreen.bookmarksTab));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Chapter Two'), findsOneWidget); // Its chapter.
      await tester.tap(find.text('Page 2'));
      await tester.pumpAndSettle();
      expect(pageText(tester), 'Page 2 of 3');

      // Opened again: still there; the button takes it off.
      await tester.tap(find.byKey(ReaderScreen.backButton));
      await tester.pumpAndSettle();
      await app.open(tester, Routes.read(novel.id));
      await tester.tap(find.byKey(ReaderScreen.contentsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ReaderScreen.bookmarksTab));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove bookmark'));
      await tester.pumpAndSettle();
      expect(app.books.bookmarksOf[novel.id], isEmpty);
      expect(find.textContaining('No bookmarks yet'), findsOneWidget);
      expect(saved, greaterThan(0));
    });

    testWidgets('themes: the desk and paper change, and are remembered', (
      tester,
    ) async {
      await app.open(tester, Routes.read(novel.id));
      expect(desk(tester), ReaderTheme.light.desk);
      await tester.tap(find.byKey(ReaderScreen.displayButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ReaderScreen.themeChoice(ReaderTheme.dark)));
      await tester.pumpAndSettle();
      expect(desk(tester), ReaderTheme.dark.desk);
      expect(
        find.descendant(
          of: find.byKey(ReaderScreen.pages),
          matching: find.byWidgetPredicate(
            (w) => w is ColoredBox && w.color == ReaderTheme.dark.colors.paper,
          ),
        ),
        findsOneWidget,
      );
      expect(app.readerStore.values['preferences'], contains('"dark"'));
    });

    testWidgets('stored preferences apply from the start', (tester) async {
      app.readerStore.values['preferences'] =
          '{"theme":"sepia","fontSize":24,"sansSerif":true}';
      await app.open(tester, Routes.read(novel.id));
      expect(desk(tester), ReaderTheme.sepia.desk);
      final document =
          ProviderScope.containerOf(tester.element(find.byType(ReaderScreen)))
                  .read(readerControllerProvider(novel.id))
                  .value!
                  .document
              as EpubBookDocument;
      expect(document.typography.fontSize, 24);
      expect(document.typography.fontFamily, 'sans-serif');
    });

    testWidgets('bigger type: laid out again, same place', (tester) async {
      await app.open(tester, Routes.read(novel.id));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ReaderScreen.displayButton));
      await tester.pumpAndSettle();
      expect(find.text('18 px'), findsOneWidget);
      await tester.tap(find.byKey(ReaderScreen.fontBigger));
      await tester.tap(find.byKey(ReaderScreen.fontBigger));
      await tester.pumpAndSettle();
      expect(find.text('22 px'), findsOneWidget);
      final document =
          ProviderScope.containerOf(tester.element(find.byType(ReaderScreen)))
                  .read(readerControllerProvider(novel.id))
                  .value!
                  .document
              as EpubBookDocument;
      expect(document.typography.fontSize, 22);
      expect(pageText(tester), 'Page 2 of 3');
    });

    testWidgets('a PDF or a comic: the theme, no type settings', (
      tester,
    ) async {
      await openComic(tester);
      await tester.tap(find.byKey(ReaderScreen.displayButton));
      await tester.pumpAndSettle();
      expect(
        find.byKey(ReaderScreen.themeChoice(ReaderTheme.sepia)),
        findsOneWidget,
      );
      expect(find.byKey(ReaderScreen.fontBigger), findsNothing);
    });

    testWidgets('a link: followed, then back to where it was', (tester) async {
      final dir = Directory.systemTemp.createTempSync('jf-links-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/links.epub')
        ..writeAsBytesSync(
          epubBytes([
            '<p><a href="ch2.xhtml#note">${'see the note ' * 12}</a></p>',
            '<p>${'filler ' * 30}</p>',
            '<p>${'more ' * 30}</p><p id="note">The note.</p>',
          ]),
        );
      final book = novel.copyWith(id: 'book-links', name: 'Links');
      app.library.books = [book];
      app.books.extraFiles[book.id] = file.path;
      await app.open(tester, Routes.read(book.id));
      expect(pageText(tester), 'Page 1 of 3');

      final page = tester.getRect(find.byKey(ReaderScreen.pages));
      await tester.tapAt(page.topLeft + Offset(page.width * 0.5, 70));
      await tester.pumpAndSettle();
      expect(pageText(tester), 'Page 3 of 3');
      expect(find.text('Back to page 1'), findsOneWidget);
      await tester.tap(find.byKey(ReaderScreen.linkBack));
      await tester.pumpAndSettle();
      expect(pageText(tester), 'Page 1 of 3');
      expect(find.byKey(ReaderScreen.linkBack), findsNothing);
    });
  });
}
