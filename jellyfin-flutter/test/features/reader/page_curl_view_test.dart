import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/reader/presentation/page_curl/page_curl_painter.dart';
import 'package:jellyfin_flutter/features/reader/presentation/page_curl/page_curl_view.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late ui.FragmentProgram program;

  setUpAll(() async {
    program = await ui.FragmentProgram.fromAsset('shaders/page_curl.frag');
  });

  late List<int> turned;
  late GlobalKey<PageCurlViewState> key;

  Future<void> pump(
    WidgetTester tester, {
    int page = 1,
    bool reduceMotion = false,
  }) async {
    turned = [];
    key = GlobalKey();
    var current = page;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pageCurlProgramProvider.overrideWithValue(AsyncData(program)),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 600),
            disableAnimations: reduceMotion,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            // The test surface is wider: the view gets 400 × 600.
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
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
                    sheetImage: (i, size, ratio) async {
                      final r = ui.PictureRecorder();
                      Canvas(r)
                          .drawColor(const Color(0xFFFFFFFF), BlendMode.src);
                      return r.endRecording().toImageSync(
                        size.width.round(),
                        size.height.round(),
                      );
                    },
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
}
