import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/auth/application/auth_controller.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  void storeSession() => app.store.values[SessionStore.sessionKey] = jsonEncode(
    testSession.toJson(),
  );

  Future<AuthState> start() =>
      app.container().read(authControllerProvider.future);

  group('startup', () {
    test('nothing stored: no server, signed out', () async {
      final state = await start();
      expect(state.server, isNull);
      expect(state.signedIn, isFalse);
    });

    test('a valid stored session is restored', () async {
      storeSession();
      final state = await start();
      expect(state.session, testSession);
      expect(state.server, testServer);
    });

    test('a revoked session is dropped, the server is kept', () async {
      storeSession();
      app.auth.checkFailure = const Unauthorized();
      final state = await start();
      expect(state.signedIn, isFalse);
      expect(state.server, testServer);
      expect(state.signedOut, SignOutReason.expired);
      expect(app.store.values, isNot(contains(SessionStore.sessionKey)));
    });

    test('server unreachable: stays signed in (offline start)', () async {
      storeSession();
      app.auth.checkFailure = const ServerUnreachable(testUrl);
      expect((await start()).session, testSession);
    });

    test('unreadable stored data counts as signed out', () async {
      app.store.values[SessionStore.sessionKey] = '{not json';
      expect((await start()).signedIn, isFalse);
    });
  });

  test('connect, login and logout', () async {
    final container = app.container();
    final auth = container.read(authControllerProvider.notifier);
    await container.read(authControllerProvider.future);

    await auth.connect('jellyfin.test:8096');
    expect(container.read(authControllerProvider).value!.server, testServer);
    expect(app.store.values, contains(SessionStore.serverKey));

    await auth.login('alice', 'secret');
    expect(container.read(authControllerProvider).value!.session, testSession);
    expect(app.store.values, contains(SessionStore.sessionKey));

    await auth.logout();
    final after = container.read(authControllerProvider).value!;
    expect(after.signedIn, isFalse);
    expect(after.server, testServer, reason: 'login screen keeps the server');
    expect(after.signedOut, SignOutReason.user);
    expect(app.auth.loggedOut, [testSession]);
    expect(app.store.values, isNot(contains(SessionStore.sessionKey)));

    await auth.login('alice', 'secret');
    expect(
      container.read(authControllerProvider).value!.signedOut,
      isNull,
      reason: 'the notice is gone once signed in again',
    );
  });

  test('wrong password leaves the state unchanged', () async {
    final container = app.container();
    final auth = container.read(authControllerProvider.notifier);
    await container.read(authControllerProvider.future);
    await auth.connect('x');

    await expectLater(
      auth.login('alice', 'nope'),
      throwsA(isA<Unauthorized>()),
    );
    expect(container.read(authControllerProvider).value!.signedIn, isFalse);
  });

  test('logout works even when the server cannot be told', () async {
    storeSession();
    app.auth.logoutFailure = const ServerUnreachable(testUrl);
    final container = app.container();
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(authControllerProvider).value!.signedIn, isFalse);
    expect(app.store.values, isNot(contains(SessionStore.sessionKey)));
  });

  test('logout does not wait for a slow server', () async {
    storeSession();
    final answer = Completer<void>();
    app.auth.logoutAnswer = answer.future;
    final container = app.container();
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();
    expect(container.read(authControllerProvider).value!.signedIn, isFalse);
    expect(app.store.values, isNot(contains(SessionStore.sessionKey)));
    expect(app.auth.loggedOut, [testSession], reason: 'told, not awaited');
    answer.complete();
  });

  test('the app closing while the server is told about a logout: no error, '
      'and the session is still dropped here', () async {
    storeSession();
    final answer = Completer<void>();
    app.auth.logoutAnswer = answer.future;
    final container = app.container();
    await container.read(authControllerProvider.future);

    final logout = container.read(authControllerProvider.notifier).logout();
    container.dispose();
    answer.complete();

    await expectLater(logout, completes);
    expect(app.store.values, isNot(contains(SessionStore.sessionKey)));
  });

  test('an expired session signs out locally and keeps the server', () async {
    storeSession();
    final container = app.container();
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).sessionExpired();
    final state = container.read(authControllerProvider).value!;
    expect(state.signedIn, isFalse);
    expect(state.server, testServer);
    expect(state.signedOut, SignOutReason.expired);
    expect(app.store.values, isNot(contains(SessionStore.sessionKey)));
    expect(app.auth.loggedOut, isEmpty); // the token is already dead
  });
}
