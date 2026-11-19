import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/api/jellyfin_api.dart';
import 'package:lighthouse/api/sessions.dart';
import 'package:lighthouse/api/system.dart';
import 'package:lighthouse/api/users.dart';
import 'package:lighthouse/core/failure.dart';

import '../support/fake_http.dart';

const client = ClientInfo(deviceId: 'dev-1', device: 'pc');
const url = 'http://jellyfin.test:8096';

JellyfinApi api(FakeAdapter adapter, {String? token}) =>
    JellyfinApi(baseUrl: url, client: client, token: token, adapter: adapter);

void main() {
  test('every request carries the auth header, with the token', () async {
    final adapter = FakeAdapter(
      (_) async => json({'Id': 'u', 'Name': 'alice'}),
    );
    await api(adapter, token: 'tok').me();

    final sent = adapter.requests.single;
    expect(sent.uri.toString(), '$url/Users/Me');
    expect(
      sent.headers['Authorization'],
      client.authorizationHeader(token: 'tok'),
    );
  });

  test('login posts the credentials', () async {
    final adapter = FakeAdapter(
      (_) async => json({
        'User': {'Id': 'u', 'Name': 'alice'},
        'AccessToken': 'tok',
        'ServerId': 's',
      }),
    );
    final result = await api(adapter).authenticateByName('alice', 'secret');

    final sent = adapter.requests.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/Users/AuthenticateByName');
    expect(sent.data, {'Username': 'alice', 'Pw': 'secret'});
    expect(result.accessToken, 'tok');
  });

  test('401 is Unauthorized', () async {
    final adapter = FakeAdapter((_) async => json({}, status: 401));
    await expectLater(
      api(adapter).authenticateByName('alice', 'wrong'),
      throwsA(isA<Unauthorized>()),
    );
  });

  test('500 is ServerError with the status', () async {
    final adapter = FakeAdapter((_) async => json({}, status: 500));
    await expectLater(
      api(adapter).logout(),
      throwsA(isA<ServerError>().having((e) => e.statusCode, 'status', 500)),
    );
  });

  test('connection refused is ServerUnreachable', () async {
    final adapter = FakeAdapter(
      (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'refused',
        error: const SocketException('Connection refused'),
      ),
    );
    await expectLater(
      api(adapter).publicSystemInfo(),
      throwsA(isA<ServerUnreachable>().having((e) => e.url, 'url', url)),
    );
  });

  test('an HTML page instead of JSON is ServerError', () async {
    final adapter = FakeAdapter(
      (_) async => ResponseBody.fromString(
        '<html>router login</html>',
        200,
        headers: {
          Headers.contentTypeHeader: ['text/html'],
        },
      ),
    );
    await expectLater(
      api(adapter).publicSystemInfo(),
      throwsA(isA<ServerError>()),
    );
  });

  test('JSON without a required field is a plain ServerError (the screen '
      'says "unexpected response"; the Dart error goes to the log)', () async {
    final adapter = FakeAdapter((_) async => json({'ServerName': 'x'}));
    await expectLater(
      api(adapter).publicSystemInfo(),
      throwsA(
        isA<ServerError>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.badCertificate, 'badCertificate', isFalse),
      ),
    );
  });
}
