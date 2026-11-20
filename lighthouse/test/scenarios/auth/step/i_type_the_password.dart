import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: When I type the password {'secret'}
Future<void> iTypeThePassword(WidgetTester tester, String password) async {
  await tester.enterText(find.byKey(LoginScreen.passwordField), password);
  await tester.pump();
}
