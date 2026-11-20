import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the navigation is a bar below
Future<void> theNavigationIsABarBelow(WidgetTester tester) async {
  expect(find.byType(NavigationBar), findsOneWidget);
  expect(find.byType(NavigationRail), findsNothing);
}
