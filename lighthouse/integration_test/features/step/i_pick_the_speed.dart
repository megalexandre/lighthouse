import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: And I pick the speed {1.5}
///
/// From the player's settings panel.
Future<void> iPickTheSpeed(WidgetTester tester, num rate) async {
  await tapOn(tester, find.byKey(PlayerScreen.settingsButton));
  await waitFor(tester, find.byKey(SettingsMenu.speedRow));
  await tapOn(tester, find.byKey(SettingsMenu.speedRow));
  final item = find.byKey(SettingsMenu.speedItem(rate.toDouble()));
  await waitFor(tester, item);
  await tapOn(tester, item);
}
