import 'package:dio/dio.dart';

import '../../../api/client_info.dart';
import '../../../api/jellyfin_api.dart';
import '../../../core/failure.dart';
import 'session.dart';

/// Calls the API as the signed-in user. A 401 means the token was revoked
/// while the app was open: [onUnauthorized] sends the app back to login,
/// and the call still fails. [onReachability] hears after every call
/// whether the server answered (false: nothing did).
class SessionClient {
  SessionClient(
    this.session,
    Future<ClientInfo> Function() client, {
    required this.onUnauthorized,
    this.onReachability,
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
  final void Function({required bool reachable})? onReachability;
  final Future<JellyfinApi> _api;

  String get userId => session.userId;
  String get baseUrl => session.server.url;

  Future<T> call<T>(Future<T> Function(JellyfinApi api) request) async {
    try {
      final result = await request(await _api);
      onReachability?.call(reachable: true);
      return result;
    } on ServerUnreachable {
      onReachability?.call(reachable: false);
      rethrow;
    } on Unauthorized {
      onReachability?.call(reachable: true);
      onUnauthorized();
      rethrow;
    } on Failure {
      onReachability?.call(reachable: true);
      rethrow;
    }
  }
}
