import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then there is no navigation bar or rail
///
/// The desktop's top bar has room for the tabs.
Future<void> thereIsNoNavigationBarOrRail(WidgetTester tester) async {
  expect(find.byType(NavigationBar), findsNothing);
  expect(find.byType(NavigationRail), findsNothing);
}
