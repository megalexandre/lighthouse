import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../server/data/server_info.dart';
import '../../server/data/server_repository.dart';
import '../data/auth_repository.dart';
import '../data/session.dart';
import '../data/session_store.dart';

/// Where the user is in the connect → login flow. The router follows it.
@immutable
class AuthState {
  const AuthState({this.server, this.session});

  /// The server picked on the connect screen (kept after logout).
  final ServerInfo? server;
  final Session? session;

  bool get signedIn => session != null;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Owns the server and the session: restores them at startup and changes
/// them on connect, login and logout. Methods throw a [Failure] for the
/// screen to show; the state only changes when they succeed.
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
      return AuthState(server: server);
    } on Failure catch (e) {
      // Server unreachable or failing: stay signed in, the screens show
      // the error and retry.
      debugPrint('could not check the stored session: $e');
    }
    return AuthState(server: server, session: session);
  }

  /// Connect screen: checks [address] and makes it the current server.
  Future<void> connect(String address) async {
    final server = await ref.read(serverRepositoryProvider).probe(address);
    await _store.writeServer(server);
    state = AsyncData(AuthState(server: server));
  }

  /// Back to the connect screen to pick another server.
  Future<void> changeServer() async {
    await _store.clearServer();
    state = const AsyncData(AuthState());
  }

  Future<void> login(String username, String password) async {
    final server = state.requireValue.server;
    if (server == null) throw StateError('login before connecting');
    final session = await ref
        .read(authRepositoryProvider)
        .login(server, username, password);
    await _store.writeSession(session);
    state = AsyncData(AuthState(server: server, session: session));
  }

  /// Signs out locally even when the server cannot be told.
  Future<void> logout() async {
    final current = state.requireValue;
    final session = current.session;
    if (session == null) return;
    try {
      await ref.read(authRepositoryProvider).logout(session);
    } on Failure catch (e) {
      debugPrint('server logout failed, signing out locally: $e');
    }
    await _store.clearSession();
    state = AsyncData(AuthState(server: current.server));
  }
}
