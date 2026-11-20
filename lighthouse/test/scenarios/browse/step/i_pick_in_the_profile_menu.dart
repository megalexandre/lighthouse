import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

const _items = {
  'the other mode': FloatingTopBar.themeItem,
  'Settings': FloatingTopBar.settingsItem,
  'Sign out': FloatingTopBar.signOutItem,
};

/// Usage: When I pick {'Settings'} in the profile menu
///
/// The menu under the user's initial, in the bar.
Future<void> iPickInTheProfileMenu(WidgetTester tester, String item) async {
  await tester.tap(find.byKey(FloatingTopBar.profileButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(_items[item]!));
  await tester.pumpAndSettle();
}
