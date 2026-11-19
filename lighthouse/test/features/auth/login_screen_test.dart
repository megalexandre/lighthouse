import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  /// Starts on the login screen: a server is stored, nobody signed in.
  setUp(() {
    app = TestApp();
    app.store.values[SessionStore.serverKey] = jsonEncode(testServer.toJson());
  });

  Future<void> signIn(WidgetTester tester, String user, String pw) async {
    await tester.enterText(find.byKey(LoginScreen.usernameField), user);
    await tester.enterText(find.byKey(LoginScreen.passwordField), pw);
    await tester.tap(find.byKey(LoginScreen.submitButton));
    await tester.pumpAndSettle();
  }

  testWidgets('a stored server opens on the login screen', (tester) async {
    await app.pump(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.text('Test Server · http://jellyfin.test:8096'),
      findsOneWidget,
    );
  });

  testWidgets('the password is hidden', (tester) async {
    await app.pump(tester);
    final field = tester.widget<TextField>(
      find.byKey(LoginScreen.passwordField),
    );
    expect(field.obscureText, isTrue);
  });

  testWidgets('restart after login opens home directly', (tester) async {
    await app.pump(tester);
    await signIn(tester, 'alice', 'secret');

    await app.pump(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('sign out goes back to login, same server', (tester) async {
    await app.pump(tester);
    await signIn(tester, 'alice', 'secret');
    await tester.tap(find.byKey(HomeScreen.signOutButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(app.auth.loggedOut, hasLength(1));
    expect(find.textContaining('Test Server'), findsOneWidget);
  });

  testWidgets('change server goes back to connect', (tester) async {
    await app.pump(tester);
    await tester.tap(find.byKey(LoginScreen.changeServerButton));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectScreen), findsOneWidget);
    expect(app.store.values, isNot(contains(SessionStore.serverKey)));
  });
}
