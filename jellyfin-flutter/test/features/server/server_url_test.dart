import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/server/data/server_url.dart';

void main() {
  const cases = {
    'jellyfin:8096': 'http://jellyfin:8096',
    '  http://jellyfin:8096/  ': 'http://jellyfin:8096',
    'https://media.example.com': 'https://media.example.com',
    'http://192.168.1.10:8096/web/#/home.html': 'http://192.168.1.10:8096',
    'http://host:8096/web/index.html?x=1': 'http://host:8096',
    'https://example.com/jellyfin/web/': 'https://example.com/jellyfin',
    'https://example.com/jellyfin': 'https://example.com/jellyfin',
    'HTTP://Host:8096': 'http://host:8096',
  };
  for (final MapEntry(key: input, value: expected) in cases.entries) {
    test('"$input" → $expected', () {
      expect(normalizeServerUrl(input), expected);
    });
  }

  for (final input in ['', '   ', 'ftp://host', 'http://', 'http:// /x']) {
    test('"$input" is not a server address', () {
      expect(normalizeServerUrl(input), isNull);
    });
  }
}
