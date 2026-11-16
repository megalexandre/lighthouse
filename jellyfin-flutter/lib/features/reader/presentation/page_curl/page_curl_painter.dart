import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'curl_geometry.dart';

/// The page-turn shader, loaded once.
final pageCurlProgramProvider = FutureProvider<ui.FragmentProgram>(
  (_) => ui.FragmentProgram.fromAsset('shaders/page_curl.frag'),
);

/// Draws [front] curling over [under] as [curl] says (see
/// shaders/page_curl.frag). Images cover the whole canvas, at any
/// resolution.
class PageCurlPainter extends CustomPainter {
  PageCurlPainter({
    required this.program,
    required this.front,
    required this.under,
    required this.curl,
    required this.shadow,
    required this.paper,
    this.backInk = 0.18,
  });

  final ui.FragmentProgram program;
  final ui.Image front;
  final ui.Image under;
  final CurlGeometry curl;

  /// 0..1: the shadows, fading as the sheet lands.
  final double shadow;
  final Color paper;

  /// How much of the page's ink shows through its back.
  final double backInk;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
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
      ..setImageSampler(0, front)
      ..setImageSampler(1, under);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    shader.dispose();
  }

  @override
  bool shouldRepaint(PageCurlPainter old) =>
      old.curl != curl ||
      old.front != front ||
      old.under != under ||
      old.shadow != shadow ||
      old.paper != paper;
}
