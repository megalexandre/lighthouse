import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: Then I see the login screen of {'Test Server'}
///
/// The login screen, naming the server it signs in to.
Future<void> iSeeTheLoginScreenOf(WidgetTester tester, String server) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.textContaining(server), findsOneWidget);
}
