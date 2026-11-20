import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And there is no carousel
Future<void> thereIsNoCarousel(WidgetTester tester) async {
  expect(find.byKey(HomeScreen.hero), findsNothing);
}
