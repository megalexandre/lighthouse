import 'dart:async';
import 'dart:io';

/// A local HTTP proxy in front of the test server, which a test can take
/// down ([up] = false: every connection is dropped, as when a server
/// vanishes) and bring back. The app is pointed at [url] instead of the
/// server.
class FlakyProxy {
  FlakyProxy._(this._server, this._target);

  final HttpServer _server;
  final Uri _target;

  /// Passes bodies through as they are (no gunzip: the headers say gzip).
  final _client = HttpClient()..autoUncompress = false;

  /// Whether requests get through.
  bool up = true;

  String get url => 'http://127.0.0.1:${_server.port}';

  static Future<FlakyProxy> start(String target) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = FlakyProxy._(server, Uri.parse(target));
    // Each connection in a zone of its own, its errors dropped: closing
    // the proxy cancels connections still on their way to the server, and
    // HttpClient reports that ("Connection attempt cancelled") outside any
    // future the handler awaits, after the test is over.
    server.listen(
      (request) =>
          runZonedGuarded(() => unawaited(proxy._handle(request)), (_, _) {}),
    );
    return proxy;
  }

  Future<void> _handle(HttpRequest request) async {
    if (!up) {
      // Gone: the connection just closes, no answer.
      final socket = await request.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    try {
      final out = await _client.openUrl(
        request.method,
        _target.replace(
          path: request.uri.path,
          query: request.uri.hasQuery ? request.uri.query : null,
        ),
      );
      request.headers.forEach((name, values) {
        if (name == HttpHeaders.hostHeader) return;
        for (final v in values) {
          out.headers.add(name, v);
        }
      });
      out.followRedirects = false;
      await out.addStream(request);
      final back = await out.close();
      final response = request.response
        ..statusCode = back.statusCode
        ..headers.chunkedTransferEncoding = true;
      back.headers.forEach((name, values) {
        // Hop-by-hop headers: this connection's own business.
        if (name == HttpHeaders.transferEncodingHeader ||
            name == HttpHeaders.contentLengthHeader ||
            name == HttpHeaders.connectionHeader) {
          return;
        }
        for (final v in values) {
          response.headers.add(name, v);
        }
      });
      await response.addStream(back);
      await response.close();
    } on Object {
      request.response.statusCode = HttpStatus.badGateway;
      await request.response.close();
    }
  }

  Future<void> close() async {
    _client.close(force: true);
    await _server.close(force: true);
  }
}
