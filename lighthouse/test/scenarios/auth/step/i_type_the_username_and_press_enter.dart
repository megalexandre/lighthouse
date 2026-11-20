import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: When I type the username {'alice'} and press Enter
Future<void> iTypeTheUsernameAndPressEnter(
  WidgetTester tester,
  String username,
) async {
  await tester.enterText(find.byKey(LoginScreen.usernameField), username);
  await tester.testTextInput.receiveAction(TextInputAction.next);
  await tester.pumpAndSettle();
}
