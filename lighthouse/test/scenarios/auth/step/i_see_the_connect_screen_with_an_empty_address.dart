import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connect_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I see the connect screen with an empty address
Future<void> iSeeTheConnectScreenWithAnEmptyAddress(WidgetTester tester) async {
  expect(find.byType(ConnectScreen), findsOneWidget);
  final field = tester.widget<TextField>(find.byKey(ConnectScreen.urlField));
  expect(field.controller!.text, isEmpty);
}
