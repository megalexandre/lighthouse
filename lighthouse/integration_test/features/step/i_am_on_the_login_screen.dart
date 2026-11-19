import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';
import 'world.dart';

/// Usage: Then I am on the login screen
///
/// Nobody signed in, nothing kept.
Future<void> iAmOnTheLoginScreen(WidgetTester tester) async {
  await waitFor(tester, find.byType(LoginScreen));
  // The screen before it may still be leaving.
  await settleRoute(tester);
  expect(find.byType(HomeScreen), findsNothing);
  expect(store.values, isNot(contains(SessionStore.sessionKey)));
}
