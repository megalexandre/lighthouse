import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';

/// Usage: When I pick the speed {1.5}
///
/// In the open settings panel, its Speed row.
Future<void> iPickTheSpeed(WidgetTester tester, num rate) async {
  await tester.tap(find.byKey(SettingsMenu.speedRow));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(SettingsMenu.speedItem(rate.toDouble())));
  await tester.pumpAndSettle();
}
