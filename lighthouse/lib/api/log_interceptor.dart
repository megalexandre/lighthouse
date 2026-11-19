import 'package:dio/dio.dart';

import '../core/log.dart';

/// Logs every request: method, path (query redacted), status and time.
/// Bodies are left out: they hold passwords and personal data.
class RequestLogInterceptor extends Interceptor {
  static const _started = 'log.started';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_started] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log.debug('http', _line(response.requestOptions, '${response.statusCode}'));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    log.warning(
      'http',
      _line(err.requestOptions, status == null ? err.type.name : '$status'),
    );
    handler.next(err);
  }

  String _line(RequestOptions options, String outcome) {
    final started = options.extra[_started] as DateTime?;
    final ms = started == null
        ? ''
        : ' ${DateTime.now().difference(started).inMilliseconds} ms';
    return '${options.method} ${options.uri} → $outcome$ms';
  }
}
