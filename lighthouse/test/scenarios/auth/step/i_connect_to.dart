import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';

/// Usage: When I connect to {'http://jellyfin.test:8096'}
///
/// Types the address and taps Connect.
Future<void> iConnectTo(WidgetTester tester, String address) async {
  await tester.enterText(find.byKey(ConnectScreen.urlField), address);
  await tester.tap(find.byKey(ConnectScreen.submitButton));
  await tester.pumpAndSettle();
}
