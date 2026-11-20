import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';

/// Usage: And I open the speed list
///
/// In the open settings panel.
Future<void> iOpenTheSpeedList(WidgetTester tester) async {
  await tester.tap(find.byKey(SettingsMenu.speedRow));
  await tester.pumpAndSettle();
}
