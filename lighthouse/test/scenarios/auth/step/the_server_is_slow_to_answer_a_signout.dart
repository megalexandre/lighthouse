import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the server is slow to answer a sign-out
///
/// It never answers within the scenario: the app must not wait for it.
Future<void> theServerIsSlowToAnswerASignout(WidgetTester tester) async {
  app.auth.logoutAnswer = Completer<void>().future;
}
