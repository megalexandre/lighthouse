import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session.dart';
import 'package:jellyfin_flutter/features/server/data/server_info.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';
import 'package:jellyfin_flutter/features/server/presentation/connect_screen.dart';
import 'package:material_ui/material_ui.dart';

const testUrl = 'http://jellyfin.test:8096';

const testServer = ServerInfo(
  url: testUrl,
  id: 'server-id',
  name: 'Test Server',
  version: '12.4.0',
);

const testSession = Session(
  server: testServer,
  userId: 'user-id',
  userName: 'alice',
  token: 'token-1',
);

/// Accepts [testServer] at any address unless [probeFailure] is set.
class FakeServerRepository implements ServerRepository {
  Failure? probeFailure;
  final probed = <String>[];

  @override
  Future<ServerInfo> probe(String input) async {
    probed.add(input);
    if (probeFailure != null) throw probeFailure!;
    return testServer;
  }
}

/// Knows one user, alice / secret.
class FakeAuthRepository implements AuthRepository {
  /// Thrown by [check]; null means the session is valid.
  Failure? checkFailure;

  /// Thrown by [logout].
  Failure? logoutFailure;

  final loggedOut = <Session>[];

  @override
  Future<Session> login(
    ServerInfo server,
    String username,
    String password,
  ) async {
    if (username != 'alice' || password != 'secret') {
      throw const Unauthorized();
    }
    return testSession.copyWith(server: server);
  }

  @override
  Future<void> check(Session session) async {
    if (checkFailure != null) throw checkFailure!;
  }

  @override
  Future<void> logout(Session session) async {
    loggedOut.add(session);
    if (logoutFailure != null) throw logoutFailure!;
  }
}

/// The app with fake server/auth repositories and an in-memory keyring.
class TestApp {
  TestApp({MemoryKeyValueStore? store})
    : store = store ?? MemoryKeyValueStore();

  final MemoryKeyValueStore store;
  final servers = FakeServerRepository();
  final auth = FakeAuthRepository();

  /// Prefilled on the connect screen (empty, as in a normal build).
  String defaultServerAddress = '';

  List<Override> get overrides => [
    keyValueStoreProvider.overrideWithValue(store),
    serverRepositoryProvider.overrideWithValue(servers),
    authRepositoryProvider.overrideWithValue(auth),
    defaultServerAddressProvider.overrideWithValue(defaultServerAddress),
  ];

  ProviderContainer container() => ProviderContainer.test(overrides: overrides);

  /// Pumps a fresh app (new providers, same store): what a restart does.
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: overrides,
        child: const JellyfinApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}
