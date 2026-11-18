import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:jellyfin_flutter/router.dart';

import 'world.dart';

/// Usage: When I open Settings
///
/// Starts the app first if it is not running.
Future<void> iOpenSettings(WidgetTester tester) async {
  if (find.byType(JellyfinApp).evaluate().isEmpty) await app.pump(tester);
  app.containerOf(tester).read(routerProvider).go(Routes.settings);
  await tester.pumpAndSettle();
  expect(find.byType(SettingsScreen), findsOneWidget);
}
