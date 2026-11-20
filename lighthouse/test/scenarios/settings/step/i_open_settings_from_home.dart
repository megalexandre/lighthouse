import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open Settings from home
///
/// Its button in home's top bar.
Future<void> iOpenSettingsFromHome(WidgetTester tester) async {
  await app.open(tester, Routes.home);
  await tester.tap(find.byKey(HomeScreen.settingsButton));
  await tester.pumpAndSettle();
  expect(find.byType(SettingsScreen), findsOneWidget);
}
