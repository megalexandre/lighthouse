import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/spreads.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('one page at a time', () {
    const spreads = Spreads(5, twoPages: false);

    test('each page is its own sheet', () {
      expect(spreads.count, 5);
      for (var page = 0; page < 5; page++) {
        expect(spreads.of(page), page);
        expect(spreads.left(page), isNull);
        expect(spreads.right(page), page);
        expect(spreads.first(page), page);
        expect(spreads.last(page), page);
      }
    });
  });

  group('two pages side by side', () {
    test('the cover alone on the right, then odd pages on the left', () {
      const spreads = Spreads(5, twoPages: true);
      expect(spreads.count, 3);
      expect(
        [for (var i = 0; i < 3; i++) (spreads.left(i), spreads.right(i))],
        [(null, 0), (1, 2), (3, 4)],
      );
      expect([for (var p = 0; p < 5; p++) spreads.of(p)], [0, 1, 1, 2, 2]);
    });

    test('an even count ends with a page alone on the left', () {
      const spreads = Spreads(4, twoPages: true);
      expect(spreads.count, 3);
      expect((spreads.left(2), spreads.right(2)), (3, null));
      expect(spreads.first(2), 3);
      expect(spreads.last(2), 3);
      expect(spreads.of(3), 2);
    });

    test('first and last: where the reader is, and how far they got', () {
      const spreads = Spreads(5, twoPages: true);
      expect((spreads.first(0), spreads.last(0)), (0, 0));
      expect((spreads.first(1), spreads.last(1)), (1, 2));
      expect((spreads.first(2), spreads.last(2)), (3, 4));
    });

    test('one page, or none', () {
      expect(const Spreads(1, twoPages: true).count, 1);
      expect(const Spreads(0, twoPages: true).count, 0);
    });
  });

  group('when two pages are shown', () {
    const epub = 0.72;

    test('as asked, whatever the room', () {
      const phone = Size(340, 680);
      expect(
        showsTwoPages(PageLayout.double, phone, epub, small: false),
        isTrue,
      );
      const desktop = Size(1576, 1088);
      expect(
        showsTwoPages(PageLayout.single, desktop, epub, small: false),
        isFalse,
      );
    });

    test('never on a small screen (a phone), even when asked', () {
      // A phone on its side: wide, but short.
      const sideways = Size(784, 344);
      for (final layout in PageLayout.values) {
        expect(showsTwoPages(layout, sideways, epub, small: true), isFalse);
      }
    });

    test('automatic: on a wide room, when each page is big enough', () {
      // A desktop window, and a laptop one.
      expect(
        showsTwoPages(
          PageLayout.auto,
          const Size(1576, 1088),
          epub,
          small: false,
        ),
        isTrue,
      );
      expect(
        showsTwoPages(
          PageLayout.auto,
          const Size(1342, 656),
          epub,
          small: false,
        ),
        isTrue,
      );
      // 800×600: wide, but two pages would be too small.
      expect(
        showsTwoPages(
          PageLayout.auto,
          const Size(776, 488),
          epub,
          small: false,
        ),
        isFalse,
      );
      // Tall: one page, however big.
      expect(
        showsTwoPages(
          PageLayout.auto,
          const Size(876, 1288),
          epub,
          small: false,
        ),
        isFalse,
      );
    });
  });
}
