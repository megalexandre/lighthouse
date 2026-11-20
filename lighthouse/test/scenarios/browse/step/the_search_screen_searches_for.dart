import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the search screen searches for {'test'}
Future<void> theSearchScreenSearchesFor(
  WidgetTester tester,
  String text,
) async {
  expect(find.byType(SearchScreen), findsOneWidget);
  expect(
    tester.widget<TextField>(find.byKey(SearchScreen.field)).controller!.text,
    text,
  );
}
