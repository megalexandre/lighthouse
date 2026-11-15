import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/api/jellyfin_api.dart';
import 'package:jellyfin_flutter/api/users.dart';
import 'package:jellyfin_flutter/core/log.dart';

import '../support/fake_http.dart';

void main() {
  group('redact', () {
    const cases = [
      // A subtitle DeliveryUrl and a transcode URL, as the server sends.
      (
        '/Videos/x/x/Subtitles/0/0/Stream.subrip?ApiKey=58965010b938',
        '/Videos/x/x/Subtitles/0/0/Stream.subrip?ApiKey=***',
      ),
      (
        '/videos/x/master.m3u8?DeviceId=d&api_key=abc123&VideoCodec=h264',
        '/videos/x/master.m3u8?DeviceId=d&api_key=***&VideoCodec=h264',
      ),
      (
        'MediaBrowser Client="J", DeviceId="d", Token="0123456789abcdef"',
        'MediaBrowser Client="J", DeviceId="d", Token="***"',
      ),
      ('{"AccessToken":"tok","User":{}}', '{"AccessToken":"***","User":{}}'),
      ('{"Username":"alice","Pw":"secret"}', '{"Username":"alice","Pw":"***"}'),
      ('nothing secret here', 'nothing secret here'),
    ];
    for (final (text, expected) in cases) {
      test(text, () => expect(redact(text), expected));
    }
  });

  test('every line is redacted and kept in memory', () {
    final log = AppLog(clock: () => DateTime(2026, 11, 15, 12));
    log.warning('http', 'GET /x?api_key=abc → 500');
    expect(
      log.recent.single,
      '2026-11-15T12:00:00.000 WARNING [http] GET /x?api_key=*** → 500',
    );
  });

  test('the file: written, and the last run rotated away', () async {
    final dir = await Directory.systemTemp.createTemp('jf-log-');
    addTearDown(() => dir.delete(recursive: true));
    File('${dir.path}/app.log').writeAsStringSync('run 1\n');

    final log = AppLog();
    await log.openFile(dir);
    log.info('app', 'run 2');
    await log.close();

    expect(File('${dir.path}/app.1.log').readAsStringSync(), 'run 1\n');
    expect(
      File('${dir.path}/app.log').readAsStringSync(),
      contains('[app] run 2'),
    );
  });

  test('keeps a few old files, not more', () async {
    final dir = await Directory.systemTemp.createTemp('jf-log-');
    addTearDown(() => dir.delete(recursive: true));
    for (var run = 0; run < AppLog.keptFiles + 3; run++) {
      final log = AppLog();
      await log.openFile(dir);
      log.info('app', 'run $run');
      await log.close();
    }
    final names = dir.listSync().map((f) => f.uri.pathSegments.last).toSet();
    expect(names, {
      'app.log',
      for (var n = 1; n <= AppLog.keptFiles; n++) 'app.$n.log',
    });
  });

  test('the log directory follows XDG_DATA_HOME, else ~/.local/share', () {
    expect(
      defaultLogDirectory({'XDG_DATA_HOME': '/data', 'HOME': '/home/a'}).path,
      '/data/jellyfin-flutter/logs',
    );
    expect(
      defaultLogDirectory({'HOME': '/home/a'}).path,
      '/home/a/.local/share/jellyfin-flutter/logs',
    );
  });

  test('requests are logged with status, and without the token', () async {
    final adapter = FakeAdapter((_) async => json({}, status: 401));
    final api = JellyfinApi(
      baseUrl: 'http://jellyfin.test:8096',
      client: const ClientInfo(deviceId: 'd', device: 'pc'),
      token: 'secret-token',
      adapter: adapter,
    );
    await expectLater(api.me(), throwsA(anything));
    final line = log.recent.lastWhere((l) => l.contains('[http]'));
    expect(line, contains('GET http://jellyfin.test:8096/Users/Me → 401'));
    expect(log.recent.join('\n'), isNot(contains('secret-token')));
  });
}
