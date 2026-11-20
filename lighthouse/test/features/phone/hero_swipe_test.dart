import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';
import 'package:lighthouse/features/home/presentation/hero_controls.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// On touch the carousel is swiped; its dots only show where it is (a 6 px
// dot is no target for a finger).
void main() {
  int shown(WidgetTester tester) {
    for (var i = 0; ; i++) {
      if (tester.widget<HeroDot>(find.byKey(HeroCarousel.dot(i))).on) return i;
    }
  }

  testWidgets('a swipe to the left shows the next slide, to the right the '
      'one before', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    expect(shown(tester), 0);

    await tester.fling(find.byType(HeroCarousel), const Offset(-200, 0), 1000);
    await tester.pumpAndSettle();
    expect(shown(tester), 1);

    await tester.fling(find.byType(HeroCarousel), const Offset(200, 0), 1000);
    await tester.pumpAndSettle();
    expect(shown(tester), 0);
  });

  testWidgets('a slow drag does not change the slide', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.timedDrag(
      find.byType(HeroCarousel),
      const Offset(-60, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(shown(tester), 0);
  });

  testWidgets('the dots are no buttons on touch', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(HeroCarousel.dot(1)), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(shown(tester), 0);
    expect(
      find.descendant(
        of: find.byKey(HeroCarousel.dot(1)),
        matching: find.byType(GestureDetector),
      ),
      findsNothing,
    );
  });
}
