import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';

/// Usage: When I type the address {'http://jellyfin.test:8096'} and press Enter
Future<void> iTypeTheAddressAndPressEnter(
  WidgetTester tester,
  String address,
) async {
  await tester.enterText(find.byKey(ConnectScreen.urlField), address);
  await tester.testTextInput.receiveAction(TextInputAction.go);
  await tester.pumpAndSettle();
}
