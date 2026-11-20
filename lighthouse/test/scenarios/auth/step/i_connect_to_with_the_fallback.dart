import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';

/// Usage: When I connect to {'fedora.local'} with the fallback {'jellyfin.example.com'}
///
/// Types both addresses and taps Connect.
Future<void> iConnectToWithTheFallback(
  WidgetTester tester,
  String address,
  String fallback,
) async {
  await tester.enterText(find.byKey(ConnectScreen.urlField), address);
  await tester.enterText(find.byKey(ConnectScreen.fallbackField), fallback);
  await tester.tap(find.byKey(ConnectScreen.submitButton));
  await tester.pumpAndSettle();
}
