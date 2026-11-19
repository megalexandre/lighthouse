import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: Then I see {'Test Movie'} among the {'Movies'}
///
/// In the row of results with that title.
Future<void> iSeeAmongThe(WidgetTester tester, String name, String row) async {
  expect(
    find.descendant(
      of: find.byWidgetPredicate((w) => w is ItemRow && w.title == row),
      matching: find.text(name),
    ),
    findsOneWidget,
  );
}
