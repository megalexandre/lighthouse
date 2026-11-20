import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart' as world;

/// Usage: Given the app is signed in
///
/// In English, as the other tests. Not started yet: the first `When`
/// starts it, so the steps in between can set things up.
Future<void> theAppIsSignedIn(WidgetTester tester) async {
  useDesktopWindow(tester);
  world.app = TestApp()..signIn();
}
