import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I tap the dot {3} of the carousel
///
/// Counted from 1.
Future<void> iTapTheDotOfTheCarousel(WidgetTester tester, num dot) async {
  await tester.tap(find.byKey(HeroCarousel.dot(dot.toInt() - 1)));
  await tester.pumpAndSettle();
}
