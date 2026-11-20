import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';

/// Usage: Then I see Settings
Future<void> iSeeSettings(WidgetTester tester) async {
  expect(find.byType(SettingsScreen), findsOneWidget);
}
