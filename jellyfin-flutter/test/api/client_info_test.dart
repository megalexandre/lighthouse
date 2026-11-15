import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/config.dart';

void main() {
  const client = ClientInfo(deviceId: 'abc123', device: 'my-pc');

  test('header without a token', () {
    expect(
      client.authorizationHeader(),
      'MediaBrowser Client="Jellyfin%20Flutter", Device="my-pc", '
      'DeviceId="abc123", Version="$appVersion"',
    );
  });

  test('header with a token', () {
    expect(client.authorizationHeader(token: 'tok'), endsWith(', Token="tok"'));
  });

  test('values are URL-encoded, as the server URL-decodes them', () {
    const odd = ClientInfo(deviceId: 'id', device: 'Living "room", TV+1');
    final header = odd.authorizationHeader();
    expect(header, contains('Device="Living%20%22room%22%2C%20TV%2B1"'));
    // Decoding gives the name back, as WebUtility.UrlDecode does on the server.
    final device = RegExp(r'Device="([^"]*)"').firstMatch(header)!.group(1)!;
    expect(Uri.decodeComponent(device), 'Living "room", TV+1');
  });
}
