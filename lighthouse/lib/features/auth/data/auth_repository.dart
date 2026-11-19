import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/jellyfin_api.dart';
import '../../../api/sessions.dart';
import '../../../api/users.dart';
import '../../../core/failure.dart';
import '../../server/data/server_info.dart';
import 'session.dart';

abstract interface class AuthRepository {
  /// Throws [Unauthorized] on wrong credentials, or another [Failure].
  Future<Session> login(ServerInfo server, String username, String password);

  /// Throws [Unauthorized] when the server no longer accepts the session.
  Future<void> check(Session session);

  /// Revokes the session's token on the server.
  Future<void> logout(Session session);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => JellyfinAuthRepository(() => ref.read(clientInfoProvider.future)),
);

class JellyfinAuthRepository implements AuthRepository {
  JellyfinAuthRepository(this._client);

  final Future<ClientInfo> Function() _client;

  Future<JellyfinApi> _api(String url, {String? token}) async =>
      JellyfinApi(baseUrl: url, client: await _client(), token: token);

  @override
  Future<Session> login(
    ServerInfo server,
    String username,
    String password,
  ) async {
    final api = await _api(server.url);
    final result = await api.authenticateByName(username, password);
    return Session(
      server: server,
      userId: result.user.id,
      userName: result.user.name,
      token: result.accessToken,
    );
  }

  @override
  Future<void> check(Session session) async {
    final api = await _api(session.server.url, token: session.token);
    await api.me();
  }

  @override
  Future<void> logout(Session session) async {
    final api = await _api(session.server.url, token: session.token);
    await api.logout();
  }
}
