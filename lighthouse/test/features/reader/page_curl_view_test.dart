import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/page_curl_painter.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/page_curl_view.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late ui.FragmentProgram program;

  setUpAll(() async {
    program = await ui.FragmentProgram.fromAsset('shaders/page_curl.frag');
  });

  late List<int> turned;
  late GlobalKey<PageCurlViewState> key;

  /// A blank sheet image of [size].
  ui.Image blank(Size size) {
    final r = ui.PictureRecorder();
    Canvas(r).drawColor(const Color(0xFFFFFFFF), BlendMode.src);
    return r.endRecording().toImageSync(
      size.width.round(),
      size.height.round(),
    );
  }

  /// The view, 400 × 600; with [twoPages] a spread twice as wide, each
  /// spread but the first (the cover) with a left page.
  Future<void> pump(
    WidgetTester tester, {
    int page = 1,
    bool reduceMotion = false,
    bool twoPages = false,
  }) async {
    turned = [];
    key = GlobalKey();
    var current = page;
    final width = twoPages ? 800.0 : 400.0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pageCurlProgramProvider.overrideWithValue(AsyncData(program)),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 600),
            disableAnimations: reduceMotion,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            // The test surface is wider: the view gets width × 600.
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                height: 600,
                child: StatefulBuilder(
                  builder: (context, setState) => PageCurlView(
                    key: key,
                    pageCount: 5,
                    page: current,
                    sheetBuilder: (i) => ColoredBox(
                      color: const Color(0xFFFFFFFF),
                      child: Center(child: Text('Sheet $i')),
                    ),
                    sheetImage: (i, size, ratio) async => blank(size),
                    leftBuilder: !twoPages
                        ? null
                        : (i) => i == 0
                              ? const SizedBox.shrink()
                              : Center(child: Text('Left $i')),
                    leftImage: !twoPages
                        ? null
                        : (i, size, ratio) async => i == 0 ? null : blank(size),
                    onTurned: (p) => setState(() {
                      turned.add(p);
                      current = p;
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder curlPainter() => find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is PageCurlPainter,
  );

  testWidgets('the sheet follows the finger, bent by the shader', (
    tester,
  ) async {
    await pump(tester);
    final gesture = await tester.startGesture(const Offset(380, 300));
    await gesture.moveBy(const Offset(-40, 0));
    await gesture.moveBy(const Offset(-80, -10));
    await tester.pump();
    expect(curlPainter(), findsOneWidget);
    final painter =
        tester.widget<CustomPaint>(curlPainter()).painter! as PageCurlPainter;
    expect(painter.curl.radius, greaterThan(0));
    expect(painter.shadow, greaterThan(0));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('let go before the middle: it falls back', (tester) async {
    await pump(tester);
    await tester.timedDragFrom(
      const Offset(380, 300),
      const Offset(-100, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(turned, isEmpty);
    expect(find.text('Sheet 1'), findsOneWidget);
    expect(curlPainter(), findsNothing);
  });

  testWidgets('past the middle: it turns', (tester) async {
    await pump(tester);
    await tester.timedDragFrom(
      const Offset(380, 300),
      const Offset(-300, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(turned, [2]);
    expect(find.text('Sheet 2'), findsOneWidget);
  });

  testWidgets('a flick turns, even a short one', (tester) async {
    await pump(tester);
    await tester.flingFrom(const Offset(380, 300), const Offset(-80, 0), 1500);
    await tester.pumpAndSettle();
    expect(turned, [2]);
  });

  testWidgets('from the left half: the previous page comes back', (
    tester,
  ) async {
    await pump(tester);
    await tester.timedDragFrom(
      const Offset(40, 300),
      const Offset(300, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(turned, [0]);
  });

  testWidgets('no page before the first, none after the last', (tester) async {
    await pump(tester, page: 0);
    await tester.flingFrom(const Offset(40, 300), const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(turned, isEmpty);

    await pump(tester, page: 4);
    key.currentState!.turnNext();
    await tester.pumpAndSettle();
    expect(turned, isEmpty);
  });

  testWidgets('turnNext plays the turn, then the page changes', (tester) async {
    await pump(tester);
    key.currentState!.turnNext();
    await tester.pump(); // the animation starts
    await tester.pump(const Duration(milliseconds: 150));
    expect(curlPainter(), findsOneWidget, reason: 'mid-turn');
    expect(turned, isEmpty);
    await tester.pumpAndSettle();
    expect(turned, [2]);
  });

  testWidgets('reduce motion: pages change without the animation', (
    tester,
  ) async {
    await pump(tester, reduceMotion: true);
    key.currentState!.turnNext();
    await tester.pump();
    expect(turned, [2]);
    expect(curlPainter(), findsNothing);
  });

  testWidgets('two quick turns, the second mid-animation: two pages', (
    tester,
  ) async {
    await pump(tester, page: 0);
    key.currentState!.turnNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The first turn ends at once; the second goes on from page 1.
    key.currentState!.turnNext();
    await tester.pumpAndSettle();
    expect(turned, [1, 2]);
    expect(find.text('Sheet 2'), findsOneWidget);

    key.currentState!.turnPrevious();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    key.currentState!.turnPrevious();
    await tester.pumpAndSettle();
    expect(turned, [1, 2, 1, 0]);
  });

  testWidgets('a key held down (turns before a frame): one page each', (
    tester,
  ) async {
    await pump(tester, page: 0, reduceMotion: true);
    key.currentState!
      ..turnNext()
      ..turnNext()
      ..turnNext();
    await tester.pump();
    expect(turned, [1, 2, 3]);
  });

  testWidgets('a drag mid-animation starts from the page being turned to', (
    tester,
  ) async {
    await pump(tester, page: 0);
    key.currentState!.turnNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final gesture = await tester.startGesture(const Offset(380, 300));
    await gesture.moveBy(const Offset(-40, 0));
    await gesture.moveBy(const Offset(-300, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(turned, [1, 2]);
  });

  testWidgets('dragged back further than the middle: it comes back', (
    tester,
  ) async {
    await pump(tester);
    await tester.timedDragFrom(
      const Offset(40, 300),
      const Offset(350, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(turned, [0]);
  });

  testWidgets('dragged back only a little: it stays turned', (tester) async {
    await pump(tester);
    await tester.timedDragFrom(
      const Offset(40, 300),
      const Offset(60, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(turned, isEmpty);
  });

  group('two pages', () {
    PageCurlPainter painter(WidgetTester tester) =>
        tester.widget<CustomPaint>(curlPainter()).painter! as PageCurlPainter;

    testWidgets('both at rest, side by side', (tester) async {
      await pump(tester, twoPages: true);
      expect(find.text('Left 1'), findsOneWidget);
      expect(find.text('Sheet 1'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Left 1')).dx,
        lessThan(tester.getCenter(find.text('Sheet 1')).dx),
      );
    });

    testWidgets('the right page turns over the spine, the next left page on '
        'its back', (tester) async {
      await pump(tester, twoPages: true);
      final gesture = await tester.startGesture(const Offset(780, 300));
      await gesture.moveBy(const Offset(-40, 0));
      await gesture.moveBy(const Offset(-500, 0));
      await tester.pump();
      final p = painter(tester);
      expect(p.back, isNotNull, reason: "the next spread's left page");
      expect(p.underLeft, isNotNull, reason: "this spread's left page");
      await gesture.up();
      await tester.pumpAndSettle();
      expect(turned, [2]);
      expect(find.text('Left 2'), findsOneWidget);
    });

    testWidgets('let go before the spine: it falls back', (tester) async {
      await pump(tester, twoPages: true);
      await tester.timedDragFrom(
        const Offset(780, 300),
        const Offset(-300, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(turned, isEmpty);
    });

    testWidgets('from the left page: the previous one comes back over', (
      tester,
    ) async {
      await pump(tester, twoPages: true);
      await tester.timedDragFrom(
        const Offset(40, 300),
        const Offset(500, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(turned, [0]);
    });

    testWidgets('from the cover: nothing left of the spine beneath', (
      tester,
    ) async {
      await pump(tester, page: 0, twoPages: true);
      key.currentState!.turnNext();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final p = painter(tester);
      expect(p.underLeft, isNull);
      expect(p.back, isNotNull);
      await tester.pumpAndSettle();
      expect(turned, [1]);
    });
  });
}
