import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: When I sign in as {'alice'} with password {'secret'}
///
/// Fills in the login form and submits it.
Future<void> iSignInAsWithPassword(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byKey(LoginScreen.usernameField), username);
  await tester.enterText(find.byKey(LoginScreen.passwordField), password);
  await tester.tap(find.byKey(LoginScreen.submitButton));
  await tester.pumpAndSettle();
}
