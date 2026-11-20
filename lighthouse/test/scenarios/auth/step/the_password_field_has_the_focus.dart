import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the password field has the focus
///
/// What is typed next goes there.
Future<void> thePasswordFieldHasTheFocus(WidgetTester tester) async {
  expect(
    tester
        .widget<TextField>(find.byKey(LoginScreen.passwordField))
        .focusNode!
        .hasFocus,
    isTrue,
  );
}
