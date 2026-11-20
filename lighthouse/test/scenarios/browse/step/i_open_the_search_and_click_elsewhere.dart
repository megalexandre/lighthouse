import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I open the search and click elsewhere
///
/// The bar's search button opens its field; nothing typed, a click at
/// the bottom corner of the window.
Future<void> iOpenTheSearchAndClickElsewhere(WidgetTester tester) async {
  await tester.tap(find.byKey(FloatingTopBar.searchButton));
  await tester.pumpAndSettle();
  expect(find.byKey(FloatingTopBar.searchField), findsOneWidget);
  final window = tester.getRect(find.byType(Scaffold).first);
  await tester.tapAt(window.bottomLeft + const Offset(4, -4));
  await tester.pumpAndSettle();
}
