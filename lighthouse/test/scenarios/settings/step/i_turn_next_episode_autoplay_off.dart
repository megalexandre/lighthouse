import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';

/// Usage: When I turn next episode autoplay off
Future<void> iTurnNextEpisodeAutoplayOff(WidgetTester tester) async {
  await tester.tap(find.byKey(SettingsScreen.autoplaySwitch));
  await tester.pumpAndSettle();
}
