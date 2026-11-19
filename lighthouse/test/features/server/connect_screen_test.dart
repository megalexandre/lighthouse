import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// What a user does on the connect screen is in
// test/scenarios/auth/connect.feature. Here: a launch detail no user drives.
void main() {
  testWidgets('the address can come prefilled (dev server launch)', (
    tester,
  ) async {
    final app = TestApp()..defaultServerAddress = 'http://jellyfin:8096';
    await app.pump(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(ConnectScreen.urlField))
          .controller!
          .text,
      'http://jellyfin:8096',
    );

    await tester.tap(find.byKey(ConnectScreen.submitButton));
    await tester.pumpAndSettle();
    expect(app.servers.probed, ['http://jellyfin:8096']);
  });
}
