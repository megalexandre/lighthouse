// Frames of a page turn, as images: what the curl looks like, checked by
// eye when the shader changes (flutter test --update-goldens) and kept
// from changing by accident after that.
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/curl_geometry.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/page_curl_painter.dart';
import 'package:material_ui/material_ui.dart';

const size = Size(300, 420);
const paper = Color(0xFFFFFFFF);

/// A book-like page: a title, lines of "text", a page number.
ui.Image fakePage(int number, Color accent) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..drawColor(paper, BlendMode.src);
  final ink = Paint()..color = const Color(0xFF333333);
  canvas.drawRect(
    const Rect.fromLTWH(24, 28, 160, 14),
    Paint()..color = accent,
  );
  for (var i = 0; i < 18; i++) {
    final width = 252.0 - (i % 4 == 3 ? 90 : (i * 37) % 30);
    canvas.drawRect(Rect.fromLTWH(24, 64 + i * 18.0, width, 6), ink);
  }
  for (var i = 0; i < number; i++) {
    canvas.drawCircle(Offset(140.0 + i * 10, 400), 3, ink);
  }
  return recorder.endRecording().toImageSync(
    size.width.toInt(),
    size.height.toInt(),
  );
}

void main() {
  late ui.FragmentProgram program;
  late ui.Image front;
  late ui.Image under;

  setUpAll(() async {
    program = await ui.FragmentProgram.fromAsset('shaders/page_curl.frag');
    front = fakePage(1, const Color(0xFFAA5CC3));
    under = fakePage(2, const Color(0xFF00A4DC));
  });

  Future<void> frame(
    WidgetTester tester,
    String name,
    Offset grab,
    Offset finger, {
    double shadow = 1,
  }) async {
    final curl = curlFor(size, grab, finger)!;
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: PageCurlPainter(
              program: program,
              front: front,
              under: under,
              curl: curl,
              shadow: shadow,
              paper: paper,
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('goldens/curl_$name.png'),
    );
  }

  const middle = Offset(300, 210);
  const corner = Offset(300, 400);

  testWidgets('from the middle of the edge: an even curl', (tester) async {
    await frame(tester, 'middle_start', middle, const Offset(270, 210));
    await frame(tester, 'middle_quarter', middle, const Offset(200, 215));
    await frame(tester, 'middle_half', middle, const Offset(80, 220));
    await frame(tester, 'middle_late', middle, const Offset(-160, 225));
  });

  testWidgets('from the bottom corner, up and in: the corner first', (
    tester,
  ) async {
    await frame(tester, 'corner_peek', corner, const Offset(250, 330));
    await frame(tester, 'corner_half', corner, const Offset(110, 250));
  });

  testWidgets('landing: the shadow fades', (tester) async {
    await frame(
      tester,
      'landing',
      middle,
      const Offset(-240, 215),
      shadow: 0.3,
    );
  });
}
