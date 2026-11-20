import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/data/server_url.dart';

void main() {
  const cases = {
    // A host name alone: http, on Jellyfin's port.
    'fedora.local': 'http://fedora.local:8096',
    'fedora.local/': 'http://fedora.local:8096',
    '192.168.1.10': 'http://192.168.1.10:8096',
    'fedora.local:8096': 'http://fedora.local:8096',
    'http://fedora.local:8096/': 'http://fedora.local:8096',
    // A scheme written: its own port (a reverse proxy on 80 or 443).
    'http://fedora.local': 'http://fedora.local',
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
