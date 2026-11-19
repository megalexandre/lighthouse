import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

/// Usage: Then I see the search screen
Future<void> iSeeTheSearchScreen(WidgetTester tester) async {
  expect(find.byType(SearchScreen), findsOneWidget);
}
