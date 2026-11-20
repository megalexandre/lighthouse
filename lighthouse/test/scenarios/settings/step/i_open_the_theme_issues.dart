import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';

/// Usage: When I open the theme issues
Future<void> iOpenTheThemeIssues(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(SettingsScreen.themeIssues));
  await tester.tap(find.byKey(SettingsScreen.themeIssues));
  await tester.pumpAndSettle();
}
