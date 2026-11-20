import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: Then the carousel shows {'Test Movie'}
///
/// Its title, in capitals, at the top of home.
Future<void> theCarouselShows(WidgetTester tester, String name) async {
  expect(
    find.descendant(
      of: find.byKey(HomeScreen.hero),
      matching: find.text(name.toUpperCase()),
    ),
    findsOneWidget,
  );
}
