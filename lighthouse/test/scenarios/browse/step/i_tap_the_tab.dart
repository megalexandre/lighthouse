import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

import 'world.dart';

/// Usage: When I tap the {'Movies'} tab
///
/// In the bar over the screen; 'Home' too.
Future<void> iTapTheTab(WidgetTester tester, String name) async {
  await tester.tap(
    find.byKey(
      name == 'Home'
          ? FloatingTopBar.homeTab
          : FloatingTopBar.tab(itemNamed(name).id),
    ),
  );
  await tester.pumpAndSettle();
}
