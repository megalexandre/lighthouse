// The real server and auth repositories against the test server.
@Tags(['server'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';
import 'package:lighthouse/features/server/data/server_info.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';

void main() {
  late TestServer server;
  late TestUser user;
  const client = ClientInfo(deviceId: 'flutter-server-tests', device: 'tests');
  final servers = JellyfinServerRepository(() async => client);
  final auth = JellyfinAuthRepository(() async => client);

  /// A port nothing listens on.
  const deadUrl = 'http://127.0.0.1:9';

  setUpAll(() async => server = await TestServer.start());
  setUp(() async => user = await server.createUser(password: 'pw-123'));

  group('probe', () {
    test('finds the test server', () async {
      final info = await servers.probe(server.url);
      expect(info.url, server.url);
      expect(info.id, isNotEmpty);
      expect(info.version, startsWith('12.4'));
    });

    test("the host name alone: found on Jellyfin's port, over http", () async {
      // The test server listens on 8096, Jellyfin's own port.
      final host = Uri.parse(server.url).host;
      expect(server.url, 'http://$host:8096');
      final info = await servers.probe(host);
      expect(info.url, server.url);
    });

    test('accepts the address copied from jellyfin-web', () async {
      final info = await servers.probe('${server.url}/web/#/home.html');
      expect(info.url, server.url);
    });

    test('server down is ServerUnreachable', () async {
      await expectLater(
        servers.probe(deadUrl),
        throwsA(isA<ServerUnreachable>()),
      );
    });

    test('what is not an address at all is NotJellyfinServer', () async {
      await expectLater(
        servers.probe('http://'),
        throwsA(isA<NotJellyfinServer>()),
      );
    });

    test('a web page that is not Jellyfin is NotJellyfinServer', () async {
      // Under /api-docs the server serves other things, but no /System API.
      await expectLater(
        servers.probe('${server.url}/api-docs'),
        throwsA(isA<NotJellyfinServer>()),
      );
    });
  });

  group('login', () {
    late ServerInfo info;
    setUp(() async => info = await servers.probe(server.url));

    test('right password gives a working session', () async {
      final session = await auth.login(info, user.name, 'pw-123');
      expect(session.userId, user.id);
      expect(session.userName, user.name);
      expect(session.token, isNotEmpty);
      await auth.check(session); // the token works
    });

    test('wrong password is Unauthorized', () async {
      await expectLater(
        auth.login(info, user.name, 'wrong'),
        throwsA(isA<Unauthorized>()),
      );
    });

    test('unknown user is Unauthorized', () async {
      await expectLater(
        auth.login(info, 'nobody-${user.name}', 'pw-123'),
        throwsA(isA<Unauthorized>()),
      );
    });

    test('server down is ServerUnreachable', () async {
      await expectLater(
        auth.login(info.copyWith(url: deadUrl), user.name, 'pw-123'),
        throwsA(isA<ServerUnreachable>()),
      );
    });

    test('logout revokes the token', () async {
      final session = await auth.login(info, user.name, 'pw-123');
      await auth.logout(session);
      await expectLater(auth.check(session), throwsA(isA<Unauthorized>()));
    });
  });
}
