import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: Then I see {'40% read'} in the {'Continue reading'} row
Future<void> iSeeInTheRow(WidgetTester tester, String text, String row) async {
  expect(
    find.descendant(
      of: find.byWidgetPredicate((w) => w is ItemRow && w.title == row),
      matching: find.text(text),
    ),
    findsOneWidget,
  );
}
