import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/server/data/server_repository.dart';

import '../../support/app.dart';

import 'world.dart' as world;

/// Usage: Given I am signed in as a new user
///
/// A user of the scenario's own, signed in through the API (the login screen
/// has scenarios of its own), and the app started on home.
Future<void> iAmSignedInAsANewUser(WidgetTester tester) =>
    signInAsANewUser(tester);

/// [iAmSignedInAsANewUser], the app in its default language when
/// [asInstalled] (see `launch`).
Future<void> signInAsANewUser(
  WidgetTester tester, {
  bool asInstalled = false,
}) async {
  world.tester = tester;
  final user = world.user = await world.server.createUser();
  final info = await JellyfinServerRepository(() async => world.probe)
      .probe(world.server.url);
  final session = await JellyfinAuthRepository(() async => world.probe)
      .login(info, user.name, user.password);
  world.store = MemoryKeyValueStore()
    ..values[SessionStore.sessionKey] = jsonEncode(session.toJson());
  await launch(tester, world.store, asInstalled: asInstalled);
  await waitFor(tester, find.byKey(HomeScreen.viewsRow));
}
