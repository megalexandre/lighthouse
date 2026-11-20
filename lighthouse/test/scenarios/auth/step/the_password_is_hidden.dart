import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the password is hidden
///
/// Shown as dots, not as typed.
Future<void> thePasswordIsHidden(WidgetTester tester) async {
  expect(
    tester.widget<TextField>(find.byKey(LoginScreen.passwordField)).obscureText,
    isTrue,
  );
}
