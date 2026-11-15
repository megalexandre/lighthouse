import 'package:dio/dio.dart';

import '../../../api/client_info.dart';
import '../../../api/jellyfin_api.dart';
import '../../../core/failure.dart';
import 'session.dart';

/// Calls the API as the signed-in user. A 401 means the token was revoked
/// while the app was open: [onUnauthorized] sends the app back to login,
/// and the call still fails.
class SessionClient {
  SessionClient(
    this.session,
    Future<ClientInfo> Function() client, {
    required this.onUnauthorized,
    HttpClientAdapter? adapter,
  }) : _api = client().then(
         (c) => JellyfinApi(
           baseUrl: session.server.url,
           client: c,
           token: session.token,
           adapter: adapter,
         ),
       );

  final Session session;
  final void Function() onUnauthorized;
  final Future<JellyfinApi> _api;

  String get userId => session.userId;
  String get baseUrl => session.server.url;

  Future<T> call<T>(Future<T> Function(JellyfinApi api) request) async {
    try {
      return await request(await _api);
    } on Unauthorized {
      onUnauthorized();
      rethrow;
    }
  }
}
