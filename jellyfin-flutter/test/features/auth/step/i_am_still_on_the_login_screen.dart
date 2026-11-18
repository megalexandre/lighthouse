import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/presentation/login_screen.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';

/// Usage: And I am still on the login screen
Future<void> iAmStillOnTheLoginScreen(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  expect(find.byType(HomeScreen), findsNothing);
}
