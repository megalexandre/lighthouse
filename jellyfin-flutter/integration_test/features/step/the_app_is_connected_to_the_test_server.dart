import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/presentation/login_screen.dart';
import 'package:jellyfin_flutter/features/server/presentation/connect_screen.dart';

import '../../support/app.dart';
import 'world.dart';

/// Usage: And the app is connected to the test server
///
/// Starts the app, types the server's address and connects: the login screen.
Future<void> theAppIsConnectedToTheTestServer(WidgetTester tester) async {
  await launch(tester, store);
  await waitFor(tester, find.byType(ConnectScreen));
  await typeInto(tester, find.byKey(ConnectScreen.urlField), server.url);
  await tester.tap(find.byKey(ConnectScreen.submitButton));
  await waitFor(tester, find.byType(LoginScreen));
}
