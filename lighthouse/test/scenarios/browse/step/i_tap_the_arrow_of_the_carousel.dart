import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I tap the {'next'} arrow of the carousel
Future<void> iTapTheArrowOfTheCarousel(WidgetTester tester, String way) async {
  await tester.tap(
    find.byKey(
      way == 'next' ? HeroCarousel.nextButton : HeroCarousel.previousButton,
    ),
  );
  await tester.pumpAndSettle();
}
