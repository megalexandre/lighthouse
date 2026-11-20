import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: Then I see the login screen
Future<void> iSeeTheLoginScreen(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
}
