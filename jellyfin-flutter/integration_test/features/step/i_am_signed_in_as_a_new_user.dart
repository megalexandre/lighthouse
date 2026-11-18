import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/auth/data/session_store.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/server/data/server_repository.dart';

import '../../support/app.dart';

import 'world.dart' as world;

/// Usage: Given I am signed in as a new user
///
/// A user of the scenario's own, signed in through the API (the login screen
/// has scenarios of its own), and the app started on home.
Future<void> iAmSignedInAsANewUser(WidgetTester tester) async {
  world.tester = tester;
  final user = world.user = await world.server.createUser();
  final info = await JellyfinServerRepository(() async => world.probe)
      .probe(world.server.url);
  final session = await JellyfinAuthRepository(() async => world.probe)
      .login(info, user.name, user.password);
  world.store = MemoryKeyValueStore()
    ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  await launch(tester, world.store);
  await waitFor(tester, find.byKey(HomeScreen.viewsRow));
}
