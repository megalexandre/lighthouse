import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/client_info.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/session.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';

/// What the steps of a scenario share. The server is set up once
/// (hook/hooks.dart); the rest is made again by each scenario's first step,
/// so scenarios never see each other's user or stored session.
late TestServer server;

/// The scenario's tester, for the hooks, which get none of their own.
late WidgetTester tester;

/// The scenario's own user on the test server.
late TestUser user;

/// Stands in for the keyring: where the app keeps its server and session.
late MemoryKeyValueStore store;

/// The item the scenario opened last (its name on the server).
late String item;

/// Where the player was paused, and where the server says it stopped.
late Duration pausedAt;
late Duration savedAt;

/// The session from before a sign-out, to check the server dropped it.
late Session oldSession;

/// The app as a client of its own, for calls behind its back.
const probe = ClientInfo(deviceId: 'integration-scenarios', device: 'tests');

/// The server's item type for a fixture [name], to look it up.
String itemType(String name) => switch (name) {
  Fixtures.testMovie || Fixtures.hevcMovie => 'Movie',
  Fixtures.testComic || Fixtures.testBook || Fixtures.testNovel => 'Book',
  Fixtures.testAlbum => 'MusicAlbum',
  _ when name.startsWith('${Fixtures.testShow} S') => 'Episode',
  _ => throw ArgumentError('add "$name" to itemType'),
};

/// The user data the server keeps on [name] for the scenario's user.
Future<Map<String, dynamic>> userDataOf(String name) async {
  final found = await server.findItem(user, name, type: itemType(name));
  return found['UserData'] as Map<String, dynamic>;
}
