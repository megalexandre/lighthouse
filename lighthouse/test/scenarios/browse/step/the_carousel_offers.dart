import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And the carousel offers {'Episodes'}
///
/// Its main button.
Future<void> theCarouselOffers(WidgetTester tester, String action) async {
  expect(
    find.descendant(
      of: find.byKey(HomeScreen.hero),
      matching: find.text(action),
    ),
    findsOneWidget,
  );
}
