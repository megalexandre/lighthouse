import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/storage.dart';

import 'world.dart' as world;

/// Usage: Given a new user with password {'pw-123'}
///
/// A user of the scenario's own on the test server, and an empty keyring:
/// the app starts as on a new computer.
Future<void> aNewUserWithPassword(WidgetTester tester, String password) async {
  world.tester = tester;
  world.store = MemoryKeyValueStore();
  world.user = await world.server.createUser(password: password);
}
