import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server is told I signed out
///
/// So it ends the session there too.
Future<void> theServerIsToldISignedOut(WidgetTester tester) async {
  expect(app.auth.loggedOut, hasLength(1));
}
