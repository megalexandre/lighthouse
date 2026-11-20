import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../server/data/server_info.dart';
import '../../server/data/server_repository.dart';
import '../data/auth_repository.dart';
import '../data/session.dart';
import '../data/session_store.dart';

/// Why the user was signed out, for the login screen to say so.
enum SignOutReason {
  /// They chose to.
  user,

  /// The server no longer accepts the session (revoked, or signed out from
  /// another client).
  expired,
}

/// Where the user is in the connect → login flow. The router follows it.
@immutable
class AuthState {
  const AuthState({this.server, this.session, this.signedOut});

  /// The server picked on the connect screen (kept after logout).
  final ServerInfo? server;
  final Session? session;

  /// Set when this state comes from a sign-out, until the next change.
  final SignOutReason? signedOut;

  bool get signedIn => session != null;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Owns the server and the session: restores them at startup and changes
/// them on connect, login and logout. Methods throw a [Failure] for the
/// screen to show; the state only changes when they succeed.
///
/// The app can close while a method waits on the server. Each method takes
/// the store before its first `await`, so what it was asked to save or drop
/// still is, and sets the state only while the controller is alive.
class AuthController extends AsyncNotifier<AuthState> {
  SessionStore get _store => ref.read(sessionStoreProvider);

  @override
  Future<AuthState> build() async {
    final store = ref.watch(sessionStoreProvider);
    final session = await store.readSession();
    final server = session?.server ?? await store.readServer();
    if (session == null) return AuthState(server: server);

    try {
      await ref.read(authRepositoryProvider).check(session);
    } on Unauthorized {
      // Signed out elsewhere, or the token was revoked.
      await store.clearSession();
      return AuthState(server: server, signedOut: SignOutReason.expired);
    } on Failure catch (e) {
      // Server unreachable or failing: stay signed in, the screens show
      // the error and retry.
      log.warning('auth', 'could not check the stored session', e);
    }
    return AuthState(server: server, session: session);
  }

  /// Connect screen: checks [address] and makes it the current server.
  Future<void> connect(String address) async {
    final store = _store;
    final server = await ref.read(serverRepositoryProvider).probe(address);
    await store.writeServer(server);
    if (ref.mounted) state = AsyncData(AuthState(server: server));
  }

  /// Back to the connect screen to pick another server.
  Future<void> changeServer() async {
    await _store.clearServer();
    if (ref.mounted) state = const AsyncData(AuthState());
  }

  Future<void> login(String username, String password) async {
    final server = state.requireValue.server;
    if (server == null) throw StateError('login before connecting');
    final store = _store;
    final session = await ref
        .read(authRepositoryProvider)
        .login(server, username, password);
    await store.writeSession(session);
    if (ref.mounted) {
      state = AsyncData(AuthState(server: server, session: session));
    }
  }

  /// The server rejected the token while the app was open (revoked, or
  /// signed out from another client): back to the login screen.
  Future<void> sessionExpired() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || current.session == null) return;
    state = AsyncData(
      AuthState(server: current.server, signedOut: SignOutReason.expired),
    );
    await _store.clearSession();
  }

  /// Signs out here at once; the server is told in the background.
  ///
  /// Waiting for the server first left the user on home with no sign of
  /// progress for as long as the request took (up to the timeouts when the
  /// server is down). Telling it is best effort anyway: a sign-out must
  /// work offline too.
  Future<void> logout() async {
    final current = state.requireValue;
    final session = current.session;
    if (session == null) return;
    final store = _store;
    final auth = ref.read(authRepositoryProvider);
    state = AsyncData(
      AuthState(server: current.server, signedOut: SignOutReason.user),
    );
    unawaited(_tellServer(auth, session));
    await store.clearSession();
  }

  static Future<void> _tellServer(AuthRepository auth, Session session) async {
    try {
      await auth.logout(session);
    } on Failure catch (e) {
      // The token stays valid there until it expires or is revoked from
      // the dashboard; nothing the user can do about it here.
      log.warning('auth', 'server logout failed, signed out locally', e);
    }
  }
}
