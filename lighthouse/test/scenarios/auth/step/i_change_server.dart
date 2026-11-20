import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: When I change server
///
/// The button for it on the login screen.
Future<void> iChangeServer(WidgetTester tester) async {
  await tester.tap(find.byKey(LoginScreen.changeServerButton));
  await tester.pumpAndSettle();
}
