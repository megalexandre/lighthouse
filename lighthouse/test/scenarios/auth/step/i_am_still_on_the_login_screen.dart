import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And I am still on the login screen
Future<void> iAmStillOnTheLoginScreen(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(HomeScreen), findsNothing);
}
