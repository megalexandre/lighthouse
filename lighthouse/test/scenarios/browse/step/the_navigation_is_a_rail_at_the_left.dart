import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the navigation is a rail at the left
Future<void> theNavigationIsARailAtTheLeft(WidgetTester tester) async {
  expect(find.byType(NavigationRail), findsOneWidget);
  expect(find.byType(NavigationBar), findsNothing);
}
