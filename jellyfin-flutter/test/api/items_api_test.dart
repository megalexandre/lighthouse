// The browsing endpoints: what they send, and that everything they send is
// in the API contract (which the contract test checks against the server).
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/api/contract.dart';
import 'package:jellyfin_flutter/api/images.dart';
import 'package:jellyfin_flutter/api/items.dart';
import 'package:jellyfin_flutter/api/jellyfin_api.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/playback_info_dto.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/api/playback.dart';
import 'package:jellyfin_flutter/api/sessions.dart';
import 'package:jellyfin_flutter/api/shows.dart';
import 'package:jellyfin_flutter/api/system.dart';
import 'package:jellyfin_flutter/api/users.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/player/data/device_profile.dart';

import '../support/fake_http.dart';

const url = 'http://jellyfin.test:8096';
const client = ClientInfo(deviceId: 'dev-1', device: 'pc');

const page = {'Items': <Object>[], 'TotalRecordCount': 0, 'StartIndex': 0};
const item = {'Id': 'i', 'Name': 'n', 'Type': 'Movie'};

void main() {
  late FakeAdapter adapter;
  late JellyfinApi api;

  setUp(() {
    adapter = FakeAdapter((options) async {
      final path = options.uri.path;
      if (path == '/Items/Latest') return json([item]);
      if (path.startsWith('/Items/') || path == '/Users/Me') {
        return json({...item, 'Id': 'u'});
      }
      if (path == '/System/Info/Public') {
        return json({'Id': 's', 'ServerName': 's', 'Version': '12.4.0'});
      }
      if (path == '/Users/AuthenticateByName') {
        return json({
          'User': {'Id': 'u', 'Name': 'alice'},
          'AccessToken': 't',
          'ServerId': 's',
        });
      }
      if (path == '/Sessions/Logout' || path.startsWith('/Sessions/Playing')) {
        return json('', status: 204);
      }
      if (path.startsWith('/UserPlayedItems/')) return json({'Played': true});
      if (path.endsWith('/PlaybackInfo')) {
        return json({'MediaSources': <Object>[]});
      }
      return json(page);
    });
    api = JellyfinApi(baseUrl: url, client: client, adapter: adapter);
  });

  /// Calls every endpoint of the API layer, with every optional argument.
  Future<void> callEverything() async {
    await api.publicSystemInfo();
    await api.authenticateByName('alice', 'pw');
    await api.me();
    await api.logout();
    await api.userViews('u');
    await api.items(
      userId: 'u',
      parentId: 'p',
      recursive: true,
      includeItemTypes: [BaseItemKind.movie],
      startIndex: 0,
      limit: 10,
      fields: ['Overview'],
    );
    await api.item('u', 'i');
    await api.latest('u', parentId: 'p', limit: 5);
    await api.resume('u', limit: 5);
    await api.seasons('u', 's');
    await api.episodes('u', 's', seasonId: 'x');
    await api.nextUp('u', limit: 5);
    await api.playbackInfo(
      'i',
      PlaybackInfoDto(userId: 'u', deviceProfile: appDeviceProfile()),
    );
    const progress = PlaybackProgressInfo(
      itemId: 'i',
      mediaSourceId: 'm',
      positionTicks: 0,
      playMethod: PlayMethod.directPlay,
    );
    await api.reportPlaybackStart(progress);
    await api.reportPlaybackProgress(progress);
    await api.reportPlaybackStopped(
      const PlaybackStopInfo(itemId: 'i', mediaSourceId: 'm', positionTicks: 0),
    );
    await api.markPlayed('u', 'i');
    await api.markUnplayed('u', 'i');
  }

  test('every request goes to a contract endpoint, with listed parameters '
      'only', () async {
    await callEverything();
    final image = itemImageUrl(
      url,
      'i',
      ImageType.primary,
      tag: 't',
      maxWidth: 1,
    );
    final sent = [
      for (final r in adapter.requests) (r.method, r.uri),
      ('GET', image),
      (
        'GET',
        staticStreamUrl(url, 'i', mediaSourceId: 'm', playSessionId: 's'),
      ),
      (
        'GET',
        staticStreamUrl(
          url,
          'i',
          mediaSourceId: 'm',
          playSessionId: 's',
          audio: true,
        ),
      ),
    ];
    for (final (method, uri) in sent) {
      final endpoint = endpointFor(method, uri.path);
      expect(
        endpoint,
        isNotNull,
        reason: '$method ${uri.path} not in contract',
      );
      expect(
        uri.queryParameters.keys.where((k) => !endpoint!.query.contains(k)),
        isEmpty,
        reason: '$method ${uri.path}',
      );
    }
  });

  test('endpointFor prefers a literal path over a template', () {
    expect(endpointFor('GET', '/Items/Latest')!.path, '/Items/Latest');
    expect(endpointFor('GET', '/Items/abc')!.path, '/Items/{itemId}');
    expect(
      endpointFor('GET', '/Items/abc/Images/Primary')!.path,
      '/Items/{itemId}/Images/{imageType}',
    );
    expect(endpointFor('GET', '/Nope'), isNull);
  });

  test(
    'items sends lists as repeated parameters, kinds by server name',
    () async {
      await api.items(
        userId: 'u',
        parentId: 'p',
        recursive: true,
        includeItemTypes: [BaseItemKind.musicAlbum, BaseItemKind.series],
        sortBy: [ItemSort.parentIndex, ItemSort.name],
        descending: true,
        startIndex: 100,
        limit: 100,
      );
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/Items');
      expect(uri.queryParametersAll, {
        'userId': ['u'],
        'parentId': ['p'],
        'recursive': ['true'],
        'includeItemTypes': ['MusicAlbum', 'Series'],
        'sortBy': ['ParentIndexNumber', 'SortName'],
        'sortOrder': ['Descending'],
        'startIndex': ['100'],
        'limit': ['100'],
      });
    },
  );

  test('options left out are not sent', () async {
    await api.items(userId: 'u');
    expect(adapter.requests.single.uri.queryParameters.keys, {
      'userId',
      'recursive',
      'sortBy',
      'sortOrder',
    });
  });

  test('latest reads a JSON array', () async {
    final items = await api.latest('u');
    expect(items.single.id, 'i');
  });

  test('an object where an array is expected is ServerError', () async {
    adapter = FakeAdapter((_) async => json(page));
    api = JellyfinApi(baseUrl: url, client: client, adapter: adapter);
    await expectLater(api.latest('u'), throwsA(isA<ServerError>()));
  });

  test('image URL', () {
    expect(
      itemImageUrl(
        url,
        'abc',
        ImageType.primary,
        tag: 'tag1',
        maxWidth: 300,
      ).toString(),
      '$url/Items/abc/Images/Primary?tag=tag1&maxWidth=300&quality=90',
    );
    // A server under a path (reverse proxy).
    expect(
      itemImageUrl(
        'https://example.com/jellyfin',
        'abc',
        ImageType.backdrop,
      ).toString(),
      'https://example.com/jellyfin/Items/abc/Images/Backdrop?quality=90',
    );
  });
}
