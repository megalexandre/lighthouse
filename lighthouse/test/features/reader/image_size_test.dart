import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/data/image_size.dart';

import '../../support/epub.dart';

void main() {
  /// [bytes] padded with zeros to [length].
  Uint8List padded(List<int> bytes, int length) =>
      Uint8List(length)..setAll(0, bytes);

  List<int> ascii(String s) => s.codeUnits;
  List<int> le16(int v) => [v & 0xFF, v >> 8];
  List<int> le24(int v) => [v & 0xFF, v >> 8 & 0xFF, v >> 16];
  List<int> be16(int v) => [v >> 8, v & 0xFF];
  List<int> le32(int v) => [...le16(v & 0xFFFF), ...le16(v >> 16)];

  /// A RIFF/WEBP file whose first chunk is [chunk], with [header] at
  /// byte 20 (the chunk's data).
  Uint8List webp(String chunk, List<int> header) => padded([
    ...ascii('RIFF'),
    0, 0, 0, 0, // file size: not read
    ...ascii('WEBP'),
    ...ascii(chunk),
    0, 0, 0, 0, // chunk size: not read
    ...header,
  ], 40);

  /// A JPEG: start of image, then [segments].
  Uint8List jpeg(List<int> segments) =>
      Uint8List.fromList([0xFF, 0xD8, ...segments, 0, 0, 0, 0, 0, 0, 0, 0]);

  /// A start-of-frame segment ([marker]) of a [width] × [height] image.
  List<int> frame(int marker, int width, int height) => [
    0xFF, marker, ...be16(17), 8, ...be16(height), ...be16(width), 3, //
    ...List.filled(9, 0),
  ];

  /// A segment of another kind ([marker]), with [length] − 2 bytes of data.
  List<int> segment(int marker, int length) => [
    0xFF,
    marker,
    ...be16(length),
    ...List.filled(length - 2, 0),
  ];

  final sizes = <String, (Uint8List, ({int width, int height})?)>{
    'PNG': (Uint8List.fromList(pngHeader(640, 480)), (width: 640, height: 480)),
    'GIF': (
      padded([...ascii('GIF89a'), ...le16(320), ...le16(200)], 13),
      (width: 320, height: 200),
    ),
    'WebP, lossy': (
      // VP8: frame tag (3), start code (3), then 14-bit width and height.
      webp('VP8 ', [0, 0, 0, 0x9D, 0x01, 0x2A, ...le16(800), ...le16(600)]),
      (width: 800, height: 600),
    ),
    'WebP, lossless': (
      // VP8L: signature, then width − 1 and height − 1 in 14 bits each.
      webp('VP8L', [0x2F, ...le32(1023 | 767 << 14)]),
      (width: 1024, height: 768),
    ),
    'WebP, extended': (
      // VP8X: flags (4), then width − 1 and height − 1 in 24 bits each.
      webp('VP8X', [0, 0, 0, 0, ...le24(1919), ...le24(1079)]),
      (width: 1920, height: 1080),
    ),
    'JPEG, after other segments and a restart marker': (
      jpeg([
        ...segment(0xE0, 16), // APP0 (JFIF)
        0xFF, 0xD0, // RST0: no length
        ...segment(0xC4, 4), // DHT: a C* marker that is not a frame
        ...frame(0xC2, 1200, 900), // progressive
      ]),
      (width: 1200, height: 900),
    ),
    'JPEG, broken between segments': (
      jpeg([...segment(0xE0, 16), 0x00, 0xC0, ...frame(0xC0, 10, 10)]),
      null,
    ),
    'JPEG, no frame before the end': (jpeg(segment(0xE0, 16)), null),
    'PNG, cut short': (
      Uint8List.fromList(pngHeader(640, 480).take(20).toList()),
      null,
    ),
    'something else': (Uint8List.fromList(ascii('%PDF-1.7 and so on')), null),
    'nothing': (Uint8List(0), null),
  };

  for (final MapEntry(key: name, value: (bytes, size)) in sizes.entries) {
    test(name, () => expect(encodedImageSize(bytes), size));
  }
}
