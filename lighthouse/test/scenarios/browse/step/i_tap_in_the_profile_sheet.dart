import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

const _items = {
  'Settings': FloatingTopBar.settingsItem,
  'Sign out': FloatingTopBar.signOutItem,
};

/// Usage: When I tap {'Settings'} in the profile sheet
///
/// The items of the desktop's profile menu, in a sheet.
Future<void> iTapInTheProfileSheet(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(_items[item]!));
  await tester.pumpAndSettle();
}
