import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/hero_carousel.dart';

/// Usage: When I tap the {'info'} button of the carousel
///
/// 'play' or 'info' (More info).
Future<void> iTapTheButtonOfTheCarousel(
  WidgetTester tester,
  String button,
) async {
  await tester.tap(
    find.byKey(
      button == 'play' ? HeroCarousel.playButton : HeroCarousel.infoButton,
    ),
  );
  await tester.pumpAndSettle();
}
