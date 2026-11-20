import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: And I see the notice {'You signed out.'}
///
/// The line above the login form that says why the user is there.
Future<void> iSeeTheNotice(WidgetTester tester, String message) async {
  expect(
    find.descendant(
      of: find.byKey(LoginScreen.notice),
      matching: find.text(message),
    ),
    findsOneWidget,
  );
}
