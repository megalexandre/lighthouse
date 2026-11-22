import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'curl_geometry.dart';

/// The page-turn shader, loaded once.
final pageCurlProgramProvider = FutureProvider<ui.FragmentProgram>(
  (_) => ui.FragmentProgram.fromAsset('shaders/page_curl.frag'),
);

/// Draws [front] curling over [under] as [curl] says (see
/// shaders/page_curl.frag). Images cover the sheet, at any resolution.
///
/// One page: the sheet is the whole canvas. Two pages ([back] given): the
/// canvas is the spread and the sheet its right half, bound at the spine in
/// the middle; [back] is the page on the sheet's back (the next left page)
/// and [underLeft] the left page beneath it (none: the desk shows, beside
/// the cover).
class PageCurlPainter extends CustomPainter {
  PageCurlPainter({
    required this.program,
    required this.front,
    required this.under,
    required this.curl,
    required this.shadow,
    required this.paper,
    this.backInk = 0.18,
    this.back,
    this.underLeft,
  });

  final ui.FragmentProgram program;
  final ui.Image front;
  final ui.Image under;
  final CurlGeometry curl;

  /// 0..1: the shadows, fading as the sheet lands.
  final double shadow;
  final Color paper;

  /// How much of the page's ink shows through its back (one page).
  final double backInk;

  /// Two pages: the next left page, on the sheet's back.
  final ui.Image? back;

  /// Two pages: the left page beneath the sheet; null beside the cover.
  final ui.Image? underLeft;

  bool get _twoPages => back != null;

  @override
  void paint(Canvas canvas, Size size) {
    final sheet = _twoPages ? Size(size.width / 2, size.height) : size;
    final shader = program.fragmentShader()
      ..setFloat(0, sheet.width)
      ..setFloat(1, sheet.height)
      ..setFloat(2, curl.point.dx)
      ..setFloat(3, curl.point.dy)
      ..setFloat(4, curl.direction.dx)
      ..setFloat(5, curl.direction.dy)
      ..setFloat(6, curl.radius)
      ..setFloat(7, shadow.clamp(0, 1))
      ..setFloat(8, backInk)
      ..setFloat(9, paper.r)
      ..setFloat(10, paper.g)
      ..setFloat(11, paper.b)
      ..setFloat(12, paper.a)
      ..setFloat(13, _twoPages ? sheet.width : 0)
      ..setFloat(14, _twoPages ? 1 : 0)
      ..setFloat(15, underLeft != null ? 1 : 0)
      ..setImageSampler(0, front)
      ..setImageSampler(1, under)
      // Every sampler needs an image; one page reads neither of these.
      ..setImageSampler(2, back ?? front)
      ..setImageSampler(3, underLeft ?? under);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    shader.dispose();
  }

  @override
  bool shouldRepaint(PageCurlPainter old) =>
      old.curl != curl ||
      old.front != front ||
      old.under != under ||
      old.back != back ||
      old.underLeft != underLeft ||
      old.shadow != shadow ||
      old.paper != paper;
}
