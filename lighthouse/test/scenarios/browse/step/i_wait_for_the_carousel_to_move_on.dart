import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I wait for the carousel to move on
///
/// It does by itself, every few seconds.
Future<void> iWaitForTheCarouselToMoveOn(WidgetTester tester) async {
  await tester.pump(HeroCarousel.interval);
  await tester.pumpAndSettle();
}
