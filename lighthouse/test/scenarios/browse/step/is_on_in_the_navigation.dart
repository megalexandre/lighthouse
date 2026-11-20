import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And {'Libraries'} is on in the navigation
///
/// 'Home' or 'Libraries', in the bar below.
Future<void> isOnInTheNavigation(WidgetTester tester, String item) async {
  expect(
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
    BrowseTab.values.byName(item.toLowerCase()).index,
  );
}
