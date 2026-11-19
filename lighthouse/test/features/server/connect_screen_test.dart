import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/auth/presentation/auth_form.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  Future<void> connect(WidgetTester tester, String address) async {
    await tester.enterText(find.byKey(ConnectScreen.urlField), address);
    await tester.tap(find.byKey(ConnectScreen.submitButton));
    await tester.pumpAndSettle();
  }

  testWidgets('first start shows the connect screen', (tester) async {
    await app.pump(tester);
    expect(find.byType(ConnectScreen), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(ConnectScreen.urlField))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('the address can come prefilled (dev server launch)', (
    tester,
  ) async {
    app.defaultServerAddress = 'http://jellyfin:8096';
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

  testWidgets('an empty address is not sent', (tester) async {
    await app.pump(tester);
    await connect(tester, '  ');
    expect(find.text('Enter the server address.'), findsOneWidget);
    expect(app.servers.probed, isEmpty);
  });

  testWidgets('a server that does not answer shows why', (tester) async {
    app.servers.probeFailure = const ServerUnreachable('http://nowhere:8096');
    await app.pump(tester);
    await connect(tester, 'nowhere:8096');

    expect(find.byType(ConnectScreen), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(FormError.errorKey)).data,
      contains('Cannot reach http://nowhere:8096'),
    );
  });

  testWidgets('pressing Enter connects too', (tester) async {
    await app.pump(tester);
    await tester.enterText(find.byKey(ConnectScreen.urlField), 'jellyfin');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a working server leads to the login screen', (tester) async {
    await app.pump(tester);
    await connect(tester, 'jellyfin.test:8096');

    expect(app.servers.probed, ['jellyfin.test:8096']);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('Test Server'), findsOneWidget);
  });
}
