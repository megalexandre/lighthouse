import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I see the page of {'Test Movie'}
Future<void> iSeeThePageOf(WidgetTester tester, String name) async {
  expect(find.byType(ItemScreen), findsOneWidget);
  expect(tester.widget<Text>(find.byKey(ItemScreen.title)).data, name);
}
