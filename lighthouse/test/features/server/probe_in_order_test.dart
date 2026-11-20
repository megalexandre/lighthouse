import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/server/data/server_info.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';

ServerInfo _at(String url) =>
    ServerInfo(url: url, id: 'id', name: 'Server', version: '12.4.0');

void main() {
  const urls = ['https://a', 'http://a', 'https://a:8920', 'http://a:8096'];

  test('takes the first candidate that answers, in order', () async {
    final info = await probeInOrder(
      urls,
      (url) async =>
          url.startsWith('http:') ? _at(url) : throw ServerUnreachable(url),
    );
    expect(info.url, 'http://a');
  });

  test('a later candidate answering first does not jump the queue', () async {
    final first = Completer<ServerInfo>();
    final result = probeInOrder(
      urls.take(2).toList(),
      (url) => url == 'https://a' ? first.future : Future.value(_at(url)),
    );
    first.complete(_at('https://a'));
    expect((await result).url, 'https://a');
  });

  test('tries them all at once', () async {
    final started = <String>[];
    final pending = Completer<ServerInfo>();
    unawaited(
      probeInOrder(urls, (url) {
        started.add(url);
        return pending.future;
      }),
    );
    await Future<void>.delayed(Duration.zero);
    expect(started, urls);
  });

  test('a server not set up ends the search', () async {
    await expectLater(
      probeInOrder(
        urls,
        (url) async =>
            url == 'https://a' ? throw ServerNotSetUp(url) : _at(url),
      ),
      throwsA(isA<ServerNotSetUp>()),
    );
  });

  test("none answering: the last candidate's failure", () async {
    await expectLater(
      probeInOrder(urls, (url) async => throw ServerUnreachable(url)),
      throwsA(
        isA<ServerUnreachable>().having((e) => e.url, 'url', 'http://a:8096'),
      ),
    );
  });

  test('none answering: a refused certificate is reported first', () async {
    await expectLater(
      probeInOrder(
        urls,
        (url) async => url == 'https://a:8920'
            ? throw const ServerError('cert', badCertificate: true)
            : throw ServerUnreachable(url),
      ),
      throwsA(
        isA<ServerError>().having((e) => e.badCertificate, 'cert', isTrue),
      ),
    );
  });

  test(
    'a refused certificate does not stop an http server from winning',
    () async {
      final info = await probeInOrder(
        urls,
        (url) async => url.startsWith('https:')
            ? throw const ServerError('cert', badCertificate: true)
            : _at(url),
      );
      expect(info.url, 'http://a');
    },
  );
}
