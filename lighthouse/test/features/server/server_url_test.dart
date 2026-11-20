import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/data/server_url.dart';

void main() {
  const cases = {
    // A host name alone: https before http, the scheme's port before
    // Jellyfin's.
    'fedora.local': [
      'https://fedora.local',
      'http://fedora.local',
      'https://fedora.local:8920',
      'http://fedora.local:8096',
    ],
    '192.168.1.10/': [
      'https://192.168.1.10',
      'http://192.168.1.10',
      'https://192.168.1.10:8920',
      'http://192.168.1.10:8096',
    ],
    'example.com/jellyfin': [
      'https://example.com/jellyfin',
      'http://example.com/jellyfin',
      'https://example.com:8920/jellyfin',
      'http://example.com:8096/jellyfin',
    ],
    // A port written: that port, https then http.
    'fedora.local:8096': [
      'https://fedora.local:8096',
      'http://fedora.local:8096',
    ],
    'jellyfin:8096': ['https://jellyfin:8096', 'http://jellyfin:8096'],
    // A scheme written: only that scheme; its own port, then Jellyfin's.
    'http://fedora.local': ['http://fedora.local', 'http://fedora.local:8096'],
    'https://media.example.com': [
      'https://media.example.com',
      'https://media.example.com:8920',
    ],
    'https://example.com/jellyfin/web/': [
      'https://example.com/jellyfin',
      'https://example.com:8920/jellyfin',
    ],
    // A port written too: exactly that.
    'http://fedora.local:8096/': ['http://fedora.local:8096'],
    '  http://jellyfin:8096/  ': ['http://jellyfin:8096'],
    'http://192.168.1.10:8096/web/#/home.html': ['http://192.168.1.10:8096'],
    'http://host:8096/web/index.html?x=1': ['http://host:8096'],
    'HTTP://Host:8096': ['http://host:8096'],
    // Cut at the last `web`: the proxy's own path may have one.
    'https://host:8920/web/jellyfin/web/': ['https://host:8920/web/jellyfin'],
  };
  for (final MapEntry(key: input, value: expected) in cases.entries) {
    test('"$input" → $expected', () {
      expect(serverUrlCandidates(input), expected);
    });
  }

  for (final input in ['', '   ', 'ftp://host', 'http://', 'http:// /x']) {
    test('"$input" is not a server address', () {
      expect(serverUrlCandidates(input), isEmpty);
    });
  }
}
