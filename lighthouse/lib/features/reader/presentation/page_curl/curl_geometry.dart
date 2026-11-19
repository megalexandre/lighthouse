import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// How a page is curled at one moment: the sheet wraps around a cylinder
/// of [radius] whose axis is the fold line through [point], perpendicular
/// to [direction] (a unit vector pointing toward the lifted edge).
///
/// The model: a point of the sheet at unrolled distance `s` from the fold
/// line lies flat while `s < 0`, climbs the cylinder for `0 ≤ s ≤ πR`, and
/// past the top lies flat again, face down, at `-(s - πR)`. The shader
/// (shaders/page_curl.frag) draws exactly this.
@immutable
class CurlGeometry {
  const CurlGeometry({
    required this.point,
    required this.direction,
    required this.radius,
  });

  final Offset point;
  final Offset direction;
  final double radius;

  @override
  String toString() =>
      'CurlGeometry(point: $point, direction: $direction, radius: $radius)';
}

/// The largest curl radius for a page [size]: the fold softens as the
/// sheet lifts, up to this.
double maxCurlRadius(Size size) => size.shortestSide * 0.12;

/// Keeps [finger] where the grabbed point can really go: the sheet is
/// bound at the spine (the left edge), so the grabbed point stays within
/// its distance from the spine's top and bottom corners — inside both
/// circles; outside, the closest point that is.
Offset constrainToSpine(Size size, Offset grab, Offset finger) {
  final a = Offset.zero;
  final b = Offset(0, size.height);
  final ra = (grab - a).distance;
  final rb = (grab - b).distance;
  bool inside(Offset p, Offset c, double r) => (p - c).distance <= r + 1e-9;
  Offset onto(Offset c, double r) {
    final v = finger - c;
    return v.distance == 0 ? c : c + v / v.distance * r;
  }

  if (inside(finger, a, ra) && inside(finger, b, rb)) return finger;
  final pa = onto(a, ra);
  if (inside(pa, b, rb)) return pa;
  final pb = onto(b, rb);
  if (inside(pb, a, ra)) return pb;
  // Outside both: where the circles cross, the one nearer the finger.
  // Centres (0, 0) and (0, h): y = (ra² - rb² + h²) / 2h, x = ±√(ra² - y²).
  final h = size.height;
  final y = (ra * ra - rb * rb + h * h) / (2 * h);
  final x = math.sqrt(math.max(0, ra * ra - y * y));
  final left = Offset(-x, y);
  final right = Offset(x, y);
  return (finger - left).distance <= (finger - right).distance ? left : right;
}

/// The curl that puts the sheet's [grab] point under the [finger], or null
/// when the sheet lies flat (the finger back where it grabbed).
///
/// The fold follows the drag: dragging straight left from the middle of
/// the edge curls the whole edge evenly; dragging a corner up and in folds
/// just that corner first. The radius grows from nothing (a small drag
/// only lifts the edge) up to [maxCurlRadius].
CurlGeometry? curlFor(Size size, Offset grab, Offset finger) {
  final f = constrainToSpine(size, grab, finger);
  final delta = grab - f;
  final distance = delta.distance;
  if (distance < 0.5) return null;
  final direction = delta / distance;
  final radius = math.min(maxCurlRadius(size), distance / math.pi);
  // The grabbed point, `s` from the fold, ends up flat on top at
  // -(s - πR): its projection moved by 2s - πR, which must equal the drag.
  final s = (distance + math.pi * radius) / 2;
  return CurlGeometry(
    point: grab - direction * s,
    direction: direction,
    radius: radius,
  );
}

/// Where the finger must end for the page to be fully turned: the grabbed
/// point mirrored over the spine.
Offset turnedFinger(Offset grab) => Offset(-grab.dx, grab.dy);

/// Whether a drag released at [finger], moving at [velocity] (px/s), turns
/// the page (true) or lets it fall back (false): a flick decides; otherwise
/// whether the grabbed point passed the middle.
bool shouldTurn(Size size, Offset finger, Offset velocity) {
  const flick = 400.0;
  if (velocity.dx < -flick) return true;
  if (velocity.dx > flick) return false;
  return finger.dx < size.width / 2;
}

/// How long the page takes to finish from [from] to [to]: a full turn in
/// about 350 ms, shorter for what is left.
Duration settleDuration(Size size, Offset from, Offset to) {
  final share = ((to - from).distance / (2 * size.width)).clamp(0.15, 1.0);
  return Duration(milliseconds: (350 * share).round());
}

/// A turn started from a key or a tap: grabbed near the bottom corner, as
/// a hand turns a page.
Offset autoGrab(Size size) => Offset(size.width, size.height * 0.88);
