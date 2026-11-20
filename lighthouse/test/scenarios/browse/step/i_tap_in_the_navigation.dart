import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';

const _items = {
  'Home': BrowseFrame.homeItem,
  'Libraries': BrowseFrame.librariesItem,
  'Search': BrowseFrame.searchItem,
  'Profile': BrowseFrame.profileItem,
};

/// Usage: When I tap {'Libraries'} in the navigation
///
/// The bar below, or the rail: 'Home', 'Libraries', 'Search', 'Profile'.
Future<void> iTapInTheNavigation(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(_items[item]!));
  await tester.pumpAndSettle();
}
