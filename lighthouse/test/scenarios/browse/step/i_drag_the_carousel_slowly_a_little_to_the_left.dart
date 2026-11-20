import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I drag the carousel slowly a little to the left
///
/// 60 px in a second: no flick, and not far enough to turn the slide.
Future<void> iDragTheCarouselSlowlyALittleToTheLeft(WidgetTester tester) async {
  await tester.timedDrag(
    find.byType(HeroCarousel),
    const Offset(-60, 0),
    const Duration(seconds: 1),
  );
  await tester.pumpAndSettle();
}
