import 'dart:io';

import 'package:dio/dio.dart';

import '../core/failure.dart';
import '../core/log.dart';
import 'auth_interceptor.dart';
import 'client_info.dart';
import 'log_interceptor.dart';

/// HTTP client for one server, optionally signed in ([token]). Endpoints
/// live in extensions by area (system.dart, users.dart, items.dart...);
/// every call goes through [guard], so callers only ever see a [Failure].
class JellyfinApi {
  JellyfinApi({
    required this.baseUrl,
    required this.client,
    this.token,
    HttpClientAdapter? adapter,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 30),
           contentType: Headers.jsonContentType,
         ),
       ) {
    dio.interceptors
      ..add(AuthInterceptor(client, token: token))
      ..add(RequestLogInterceptor());
    if (adapter != null) dio.httpClientAdapter = adapter;
  }

  final String baseUrl;
  final ClientInfo client;
  final String? token;
  final Dio dio;

  /// Runs [request], turning transport errors and unreadable responses into
  /// a [Failure].
  Future<T> guard<T>(Future<T> Function(Dio dio) request) async {
    try {
      return await request(dio);
    } on DioException catch (e) {
      throw _logged(_failureOf(e));
    } on TypeError catch (e) {
      // A field missing or of the wrong type in the response.
      throw _logged(ServerError(e.toString()));
    } on FormatException catch (e) {
      throw _logged(ServerError(e.message));
    }
  }

  /// The screens show only a failure's plain message; its technical detail
  /// (why a response could not be read) goes to the log here.
  static Failure _logged(Failure failure) {
    if (failure.detail != null) log.warning('http', 'request failed', failure);
    return failure;
  }

  /// GET of a JSON object, parsed by [parse] (a model's fromJson). A
  /// response [parse] cannot read is a [ServerError].
  Future<T> getJson<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? query,
  }) => guard((dio) async {
    final res = await dio.get<Object>(path, queryParameters: query);
    return parse(_object(res));
  });

  /// GET of a JSON array of objects, each parsed by [parse].
  Future<List<T>> getJsonList<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? query,
  }) => guard((dio) async {
    final res = await dio.get<Object>(path, queryParameters: query);
    final data = res.data;
    if (data is! List) {
      throw ServerError('expected a JSON array, got ${data.runtimeType}');
    }
    return [for (final e in data) parse(e as Map<String, dynamic>)];
  });

  /// POST of [body], returning a JSON object parsed by [parse].
  Future<T> postJson<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Object? body,
    Map<String, dynamic>? query,
  }) => guard((dio) async {
    final res = await dio.post<Object>(
      path,
      data: body,
      queryParameters: query,
    );
    return parse(_object(res));
  });

  /// DELETE, returning a JSON object parsed by [parse].
  Future<T> deleteJson<T>(
    String path,
    T Function(Map<String, dynamic> json) parse, {
    Map<String, dynamic>? query,
  }) => guard((dio) async {
    final res = await dio.delete<Object>(path, queryParameters: query);
    return parse(_object(res));
  });

  /// POST with no response body (204).
  Future<void> post(String path, {Object? body}) =>
      guard((dio) => dio.post<void>(path, data: body));

  Map<String, dynamic> _object(Response<Object> res) {
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    throw ServerError('expected a JSON object, got ${data.runtimeType}');
  }

  Failure _failureOf(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ServerUnreachable(baseUrl);
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return const Unauthorized();
        return ServerError('HTTP $status', statusCode: status);
      case DioExceptionType.badCertificate:
        return const ServerError(
          'invalid TLS certificate',
          hint: "The server's security certificate is not valid.",
        );
      case DioExceptionType.cancel:
        return ServerError('request cancelled');
      case DioExceptionType.transformTimeout:
        return ServerError('response took too long to decode');
      case DioExceptionType.unknown:
        final cause = e.error;
        if (cause is SocketException ||
            cause is HttpException ||
            cause is HandshakeException) {
          return ServerUnreachable(baseUrl);
        }
        return ServerError(cause?.toString() ?? e.message ?? 'unknown error');
    }
  }
}
