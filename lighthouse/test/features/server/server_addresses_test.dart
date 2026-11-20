import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/server/data/server_info.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';

import '../../support/fakes.dart';

const home = 'fedora.local';
const away = 'jellyfin.example.com';

ServerInfo at(String url, {String id = 'server-id'}) =>
    testServer.copyWith(url: url, id: id);

/// A probe that answers from [answers] (a ServerInfo, a Failure, or a
/// Completer for an answer that has not come yet).
Future<ServerInfo> Function(String) probeWith(Map<String, Object> answers) =>
    (address) async => switch (answers[address]) {
      final ServerInfo s => s,
      final Failure f => throw f,
      final Completer<ServerInfo> c => c.future,
      _ => throw ServerUnreachable(address),
    };

void main() {
  group('connectServer', () {
    test('reached at the preferred address, both kept', () async {
      final server = await connectServer(
        [home, away],
        probeWith({
          home: at('http://fedora.local:8096'),
          away: at('https://jellyfin.example.com'),
        }),
      );
      expect(server.url, 'http://fedora.local:8096');
      expect(server.addresses, [home, away]);
    });

    test('preferred down: the fallback, still preferred later', () async {
      final server = await connectServer([
        home,
        away,
      ], probeWith({away: at('https://jellyfin.example.com')}));
      expect(server.url, 'https://jellyfin.example.com');
      expect(server.addresses, [home, away]);
    });

    test('a fallback that does not answer is kept unchecked', () async {
      final server = await connectServer([
        home,
        away,
      ], probeWith({home: at('http://fedora.local:8096')}));
      expect(server.addresses, [home, away]);
    });

    test('one address: nothing to choose from, none stored', () async {
      final server = await connectServer([
        home,
      ], probeWith({home: at('http://fedora.local:8096')}));
      expect(server.addresses, isEmpty);
    });

    test('a fallback on another server is refused', () async {
      await expectLater(
        connectServer(
          [home, away],
          probeWith({
            home: at('http://fedora.local:8096'),
            away: at('https://jellyfin.example.com', id: 'other'),
          }),
        ),
        throwsA(isA<DifferentServer>().having((e) => e.url, 'url', away)),
      );
    });

    test('none answers: the preferred address is the one reported', () async {
      await expectLater(
        connectServer([home, away], probeWith({})),
        throwsA(isA<ServerUnreachable>().having((e) => e.url, 'url', home)),
      );
    });

    test('none answers: a refused certificate is reported first', () async {
      await expectLater(
        connectServer([
          home,
          away,
        ], probeWith({away: const ServerError('tls', badCertificate: true)})),
        throwsA(isA<ServerError>()),
      );
    });
  });

  group('locateServer', () {
    final stored = at('https://jellyfin.example.com')
        .copyWith(addresses: [home, away]);

    test('the preferred address wins whenever it answers', () async {
      final found = await locateServer(
        stored,
        probeWith({
          home: at('http://fedora.local:8096'),
          away: at('https://jellyfin.example.com'),
        }),
      );
      expect(found.url, 'http://fedora.local:8096');
      expect(found.addresses, [home, away]);
    });

    test('preferred down: the fallback', () async {
      final found = await locateServer(
        stored,
        probeWith({away: at('https://jellyfin.example.com')}),
      );
      expect(found.url, 'https://jellyfin.example.com');
    });

    test('another server at the preferred address is skipped', () async {
      final found = await locateServer(
        stored,
        probeWith({
          home: at('http://fedora.local:8096', id: 'neighbour'),
          away: at('https://jellyfin.example.com'),
        }),
      );
      expect(found.url, 'https://jellyfin.example.com');
    });

    test('waits for the preferred one before taking the fallback', () async {
      final slowHome = Completer<ServerInfo>();
      var done = false;
      final found = locateServer(
        stored,
        probeWith({home: slowHome, away: at('https://jellyfin.example.com')}),
      ).whenComplete(() => done = true);
      await pumpEventQueue();
      expect(done, isFalse);
      slowHome.complete(at('http://fedora.local:8096'));
      expect((await found).url, 'http://fedora.local:8096');
    });

    test('nothing answers: unreachable at the address in use', () async {
      await expectLater(
        locateServer(stored, probeWith({})),
        throwsA(
          isA<ServerUnreachable>().having(
            (e) => e.url,
            'url',
            'https://jellyfin.example.com',
          ),
        ),
      );
    });

    test('a server stored with one address is looked for there', () async {
      final probed = <String>[];
      final found = await locateServer(testServer, (address) async {
        probed.add(address);
        return testServer;
      });
      expect(probed, [testUrl]);
      expect(found, testServer);
    });
  });
}
