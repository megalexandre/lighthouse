import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart' as world;

/// Usage: Given the app as installed
///
/// Signed in, with nothing chosen yet: the app's own default language, not
/// the English the other tests use. Not started yet: the first `When`
/// starts it.
Future<void> theAppAsInstalled(WidgetTester tester) async {
  useDesktopWindow(tester);
  world.app = TestApp(asInstalled: true)..signIn();
}
