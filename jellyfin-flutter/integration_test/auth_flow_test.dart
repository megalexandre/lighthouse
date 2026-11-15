// The real app (Linux, real plugins, libmpv loaded) against the test server:
// connect, sign in, restart signed in, sign out.
// Run: xvfb-run -a flutter test integration_test -d linux
//
// Only the keyring is swapped for an in-memory store, so the tests never
// touch your desktop's keyring (and CI has none). A "restart" is a fresh
// ProviderScope over the same store: all in-memory state is gone, only what
// was persisted survives, as after a real restart.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/auth/presentation/login_screen.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/server/presentation/connect_screen.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestServer server;
  late TestUser user;
  late MemoryKeyValueStore store;

  setUpAll(() async {
    MediaKit.ensureInitialized();
    server = await TestServer.start();
  });
  setUp(() async {
    store = MemoryKeyValueStore();
    user = await server.createUser(password: 'pw-123');
  });
  tearDown(() => server.deleteUser(user));

  /// Starts the app (or restarts it: new providers, same store).
  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
        child: const JellyfinApp(),
      ),
    );
  }

  /// Pumps until [finder] shows up. Requests here are real HTTP, so there
  /// is no "settled" moment to wait for.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .whereType<String>()
            .join(' | ');
        fail('timed out waiting for $finder. On screen: $texts');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Clicks into the field, then types, as a user would. enterText alone
  /// writes to whatever input connection is open, which is none once
  /// focus has moved to a button.
  Future<void> type(WidgetTester tester, Key field, String text) async {
    await tester.tap(find.byKey(field));
    await tester.pump();
    await tester.enterText(find.byKey(field), text);
  }

  Future<void> signIn(WidgetTester tester, String password) async {
    await type(tester, LoginScreen.usernameField, user.name);
    await type(tester, LoginScreen.passwordField, password);
    await tester.tap(find.byKey(LoginScreen.submitButton));
  }

  Future<void> connect(WidgetTester tester) async {
    await waitFor(tester, find.byType(ConnectScreen));
    await type(tester, ConnectScreen.urlField, server.url);
    await tester.tap(find.byKey(ConnectScreen.submitButton));
    await waitFor(tester, find.byType(LoginScreen));
  }

  Session storedSession() => Session.fromJson(
    jsonDecode(store.values[SessionStore.sessionKey]!) as Map<String, dynamic>,
  );

  testWidgets('connect, sign in, restart signed in, sign out', (tester) async {
    await launch(tester);
    await connect(tester);

    // Wrong password first: stays, explains.
    await signIn(tester, 'wrong');
    await waitFor(tester, find.text('Wrong username or password.'));

    // Right password.
    await signIn(tester, 'pw-123');
    await waitFor(tester, find.text('Signed in as ${user.name}'));

    final session = storedSession();
    expect(session.userId, user.id);
    expect(session.server.url, server.url);

    // Restart: straight to home, no login screen.
    await launch(tester);
    await waitFor(tester, find.byType(HomeScreen));
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Signed in as ${user.name}'), findsOneWidget);

    // Sign out: back to login, token revoked on the server.
    await tester.tap(find.byKey(HomeScreen.signOutButton));
    await waitFor(tester, find.byType(LoginScreen));
    expect(store.values, isNot(contains(SessionStore.sessionKey)));

    const probe = ClientInfo(deviceId: 'integration-probe', device: 'tests');
    await expectLater(
      JellyfinAuthRepository(() async => probe).check(session),
      throwsA(isA<Unauthorized>()),
    );
  });

  testWidgets('a session revoked while the app was closed asks to sign in '
      'again', (tester) async {
    await launch(tester);
    await connect(tester);
    await signIn(tester, 'pw-123');
    await waitFor(tester, find.byType(HomeScreen));

    // Revoked behind the app's back (e.g. signed out from the web UI).
    const probe = ClientInfo(deviceId: 'integration-probe', device: 'tests');
    await JellyfinAuthRepository(() async => probe).logout(storedSession());

    await launch(tester);
    await waitFor(tester, find.byType(LoginScreen));
    expect(find.byType(HomeScreen), findsNothing);
  });
}
