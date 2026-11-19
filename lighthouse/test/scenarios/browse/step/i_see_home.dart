import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: Then I see home
Future<void> iSeeHome(WidgetTester tester) async {
  expect(find.byType(HomeScreen), findsOneWidget);
}
