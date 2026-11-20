import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I swipe the carousel to the {'left'}
///
/// A quick flick: to the left for the next slide.
Future<void> iSwipeTheCarouselToThe(WidgetTester tester, String side) async {
  final dx = side == 'left' ? -200.0 : 200.0;
  await tester.fling(find.byType(HeroCarousel), Offset(dx, 0), 1000);
  await tester.pumpAndSettle();
}
