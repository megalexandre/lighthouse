import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';

/// Usage: And I am still on the connect screen
Future<void> iAmStillOnTheConnectScreen(WidgetTester tester) async {
  expect(find.byType(ConnectScreen), findsOneWidget);
  expect(find.byType(LoginScreen), findsNothing);
}
