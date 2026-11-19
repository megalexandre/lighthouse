import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart' as world;

/// Usage: Given the app is signed in
///
/// A fresh app, signed in to the fake server (it opens on the first
/// `When`, so the steps in between can set things up).
Future<void> theAppIsSignedIn(WidgetTester tester) async {
  world.tester = tester;
  world.app = TestApp();
}
