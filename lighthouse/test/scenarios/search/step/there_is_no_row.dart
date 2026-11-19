import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And there is no {'Songs'} row
Future<void> thereIsNoRow(WidgetTester tester, String row) async {
  expect(
    find.byWidgetPredicate((w) => w is ItemRow && w.title == row),
    findsNothing,
  );
}
