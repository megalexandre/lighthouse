import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';
import 'session.dart';
import 'world.dart';

/// Usage: Then I see the home screen signed in as the new user
///
/// Home, with the user's name on it, and the session kept for the next start.
Future<void> iSeeTheHomeScreenSignedInAsTheNewUser(WidgetTester tester) async {
  await waitFor(tester, find.byType(HomeScreen));
  // The screen before it may still be leaving.
  await settleRoute(tester);
  expect(find.byType(LoginScreen), findsNothing);
  expect(onScreen(HomeScreen, find.text(user.name)), findsOneWidget);
  final session = storedSession();
  expect(session.userId, user.id);
  expect(session.server.url, server.url);
}
