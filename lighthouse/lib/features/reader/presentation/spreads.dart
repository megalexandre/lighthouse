import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../application/reader_preferences.dart';

/// A book's pages as the reader shows them: one at a time, or in spreads,
/// two side by side as an open book. In spreads the first page (the cover)
/// is alone on the right, as in a printed book, so odd pages are always on
/// the left: spread 0 is (–, 0), spread 1 is (1, 2), spread 2 is (3, 4)...
/// The last one may be alone on the left.
@immutable
class Spreads {
  const Spreads(this.pageCount, {required this.twoPages});

  final int pageCount;

  /// Two pages side by side.
  final bool twoPages;

  /// How many sheets turn.
  int get count => !twoPages || pageCount == 0 ? pageCount : pageCount ~/ 2 + 1;

  /// The spread that shows [page].
  int of(int page) => twoPages ? (page + 1) ~/ 2 : page;

  /// The page on the left of spread [index]; null on the first spread, and
  /// always null one page at a time.
  int? left(int index) => twoPages && index > 0 ? 2 * index - 1 : null;

  /// The page on the right of spread [index] (the only one, one page at a
  /// time); null when the last page of the book is on the left.
  int? right(int index) {
    final page = twoPages ? 2 * index : index;
    return page < pageCount ? page : null;
  }

  /// The first page spread [index] shows: where the reader is.
  int first(int index) => left(index) ?? right(index)!;

  /// The last page spread [index] shows: whether the book was read through.
  int last(int index) => right(index) ?? left(index)!;

  @override
  bool operator ==(Object other) =>
      other is Spreads &&
      other.pageCount == pageCount &&
      other.twoPages == twoPages;

  @override
  int get hashCode => Object.hash(pageCount, twoPages);
}

/// The narrowest page worth showing two of: below it, two pages side by side
/// are too small to read and [PageLayout.auto] shows one.
const minSpreadPageWidth = 420.0;

/// Whether [layout] shows two pages in [room] (the space the pages get),
/// for pages [aspect] wide (width ÷ height). [PageLayout.auto] does when
/// the room is wider than tall and each of the two pages, as large as fits,
/// is at least [minSpreadPageWidth] wide. Never on a [small] screen (a
/// phone, upright or on its side): there two pages are too small to read
/// even when asked for, and the choice waits for a bigger screen.
bool showsTwoPages(
  PageLayout layout,
  Size room,
  double aspect, {
  required bool small,
}) =>
    !small &&
    switch (layout) {
      PageLayout.single => false,
      PageLayout.double => true,
      PageLayout.auto =>
        room.width > room.height &&
            math.min(room.height * aspect, room.width / 2) >=
                minSpreadPageWidth,
    };
