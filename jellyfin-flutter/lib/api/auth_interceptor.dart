import 'package:dio/dio.dart';

import 'client_info.dart';

/// Adds the Jellyfin Authorization header (client, device, token) to every
/// request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.client, {this.token});

  final ClientInfo client;
  final String? token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = client.authorizationHeader(token: token);
    handler.next(options);
  }
}
