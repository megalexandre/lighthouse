import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/app.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I open Settings
///
/// Starts the app first if it is not running.
Future<void> iOpenSettings(WidgetTester tester) async {
  if (find.byType(LighthouseApp).evaluate().isEmpty) await app.pump(tester);
  app.containerOf(tester).read(routerProvider).go(Routes.settings);
  await tester.pumpAndSettle();
  expect(find.byType(SettingsScreen), findsOneWidget);
}
