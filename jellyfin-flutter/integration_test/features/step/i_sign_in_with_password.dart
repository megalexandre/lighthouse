import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/presentation/login_screen.dart';

import '../../support/app.dart';
import 'world.dart';

/// Usage: When I sign in with password {'pw-123'}
///
/// The new user's name, [password], and the Sign in button.
Future<void> iSignInWithPassword(WidgetTester tester, String password) async {
  await typeInto(tester, find.byKey(LoginScreen.usernameField), user.name);
  await typeInto(tester, find.byKey(LoginScreen.passwordField), password);
  await tester.tap(find.byKey(LoginScreen.submitButton));
}
