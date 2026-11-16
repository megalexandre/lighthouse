// A page turning: the sheet (uFront) wraps around a cylinder over the page
// beneath (uUnder). See lib/features/reader/presentation/page_curl/
// curl_geometry.dart for the model:
//
//   s < 0          flat, face up, in place
//   0 <= s <= PI R on the cylinder (front half, then the back half)
//   s > PI R       past the top: flat again, face down, at d = -(s - PI R)
//
// where s is a point's unrolled distance from the fold line and d its
// distance on screen. Light: the front darkens as it turns away, the back
// is the page's own ink seen through thin paper (mirrored, faint), a
// specular band runs along the crest, and the lifted sheet casts a soft
// shadow on the page beneath that fades as it lands (uShadow).
#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;       // the sheet, in pixels
uniform vec2 uPoint;      // a point on the fold line
uniform vec2 uDir;        // unit vector toward the lifted edge
uniform float uRadius;    // cylinder radius
uniform float uShadow;    // 0..1: how strong the shadows are
uniform float uBackInk;   // 0..1: how much ink shows through the back
uniform vec4 uPaper;      // paper colour (the back, the empty page beneath)
uniform sampler2D uFront; // the sheet being turned
uniform sampler2D uUnder; // the page beneath it

out vec4 fragColor;

const float PI = 3.14159265359;

bool inSheet(vec2 p) {
  return p.x >= 0.0 && p.y >= 0.0 && p.x <= uSize.x && p.y <= uSize.y;
}

vec3 sampleFront(vec2 p) { return texture(uFront, p / uSize).rgb; }
vec3 sampleUnder(vec2 p) { return texture(uUnder, p / uSize).rgb; }

// The back of the sheet at source point `src`, at angle `theta` on the
// cylinder (PI when lying flat on top).
vec3 backOfSheet(vec2 src, float theta) {
  vec3 ink = mix(uPaper.rgb, sampleFront(src), uBackInk);
  // Facing up (theta = PI) it is fully lit; edge on (PI/2), darker.
  float facing = -cos(theta);
  float light = 0.72 + 0.28 * facing;
  // A soft highlight on the crest of the curve.
  float crest = exp(-pow((theta - 0.68 * PI) / 0.09, 2.0));
  return ink * light + vec3(0.18 * crest * uShadow);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float r = max(uRadius, 0.0001);
  float d = dot(p - uPoint, uDir);
  vec2 foot = p - uDir * d;

  // 1. The back of the sheet, on top of everything where it is.
  if (d <= r) {
    float theta;
    float s;
    if (d < 0.0) {
      theta = PI;
      s = PI * r - d;
    } else {
      theta = PI - asin(clamp(d / r, 0.0, 1.0));
      s = theta * r;
    }
    vec2 src = foot + uDir * s;
    if (inSheet(src)) {
      fragColor = vec4(backOfSheet(src, theta), 1.0);
      return;
    }
  }

  // 2. The front of the sheet, rising up the cylinder.
  if (d >= 0.0 && d <= r) {
    float theta = asin(clamp(d / r, 0.0, 1.0));
    vec2 src = foot + uDir * (theta * r);
    if (inSheet(src)) {
      // Turning away from the light, and into the shade of the fold.
      float light = 0.62 + 0.38 * cos(theta);
      fragColor = vec4(sampleFront(src) * light, 1.0);
      return;
    }
  }

  // 3. The sheet still lying flat, face up. Near the fold it is shaded by
  //    the curl above it.
  if (d < 0.0) {
    float shade = 1.0 - 0.22 * uShadow * exp(d / (0.7 * r + 2.0));
    fragColor = vec4(sampleFront(p) * shade, 1.0);
    return;
  }

  // 4. The page beneath, under the shadow of the lifted sheet: dark and
  //    sharp close to the curl, soft further away.
  float spread = 0.9 * r + 6.0;
  float shadow = 0.5 * uShadow * exp(-(d - r) / spread);
  fragColor = vec4(sampleUnder(p) * (1.0 - shadow), 1.0);
}
