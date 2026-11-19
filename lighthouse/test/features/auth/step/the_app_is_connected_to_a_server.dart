import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

import '../../../support/fakes.dart';
import 'world.dart' as world;

/// Usage: Given the app is connected to a server
///
/// A server was stored by an earlier run and nobody is signed in, so the
/// app opens on the login screen.
Future<void> theAppIsConnectedToAServer(WidgetTester tester) async {
  final app = world.app = TestApp();
  app.store.values[SessionStore.serverKey] = jsonEncode(testServer.toJson());
  await app.pump(tester);
  expect(find.byType(LoginScreen), findsOneWidget);
}
